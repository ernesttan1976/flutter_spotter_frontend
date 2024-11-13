// lib/features/camera/providers/camera_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraProvider extends ChangeNotifier {
  CameraController? _controller;
  bool _isInitialized = false;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _flashAvailable = false;

  // Getters
  bool get isInitialized => _isInitialized;
  CameraController get controller {
    if (_controller == null) {
      throw Exception('Camera controller not initialized');
    }
    return _controller!;
  }

  Future<void> initializeCamera() async {
    if (_cameras == null) {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) {
        throw Exception('No cameras available');
      }
    }

    final newController = CameraController(
      _cameras![_selectedCameraIndex],
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await newController.initialize();
    
    // Check flash capability after initialization
    try {
      // Try to set flash mode to check if flash is available
      await newController.setFlashMode(FlashMode.off);
      _flashAvailable = true;
    } catch (e) {
      _flashAvailable = false;
      debugPrint('Flash not available: $e');
    }

    _controller = newController;
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length <= 1) return;

    _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
    _isInitialized = false;
    notifyListeners();

    await initializeCamera();
  }

  Future<void> setZoomLevel(double zoom) async {
    if (!_isInitialized || _controller == null) return;
    await _controller!.setZoomLevel(zoom);
  }

  Future<File> takePhoto() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile photo = await _controller!.takePicture();
      final File file = File(photo.path);
      return file;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  Future<File> recordVideo() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (_controller!.value.isRecordingVideo) {
      // Stop recording
      try {
        final XFile video = await _controller!.stopVideoRecording();
        return File(video.path);
      } catch (e) {
        throw Exception('Failed to stop recording: $e');
      }
    } else {
      // Start recording
      try {
        await _controller!.startVideoRecording();
        return File(''); // Return empty file, actual file will be returned when stopping
      } catch (e) {
        throw Exception('Failed to start recording: $e');
      }
    }
  }

  Future<bool> hasFlash() async {
    if (!_isInitialized || _controller == null) return false;
    return _flashAvailable;
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (!_isInitialized || _controller == null) return;
    
    try {
      if (_flashAvailable) {
        await _controller!.setFlashMode(mode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error setting flash mode: $e');
    }
  }

  FlashMode getCurrentFlashMode() {
    if (!_isInitialized || _controller == null || !_flashAvailable) {
      return FlashMode.off;
    }
    return _controller!.value.flashMode;
  }

  Future<void> toggleFlash() async {
    if (!_isInitialized || _controller == null || !_flashAvailable) return;
    
    try {
      final currentMode = getCurrentFlashMode();
      FlashMode newMode;
      
      // Cycle through flash modes
      switch (currentMode) {
        case FlashMode.off:
          newMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          newMode = FlashMode.always;
          break;
        case FlashMode.always:
          newMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          newMode = FlashMode.off;
          break;
      }
      
      await setFlashMode(newMode);
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> setFocusMode(FocusMode mode) async {
    if (!_isInitialized || _controller == null) return;
    await _controller!.setFocusMode(mode);
    notifyListeners();
  }

  Future<void> setExposureMode(ExposureMode mode) async {
    if (!_isInitialized || _controller == null) return;
    await _controller!.setExposureMode(mode);
    notifyListeners();
  }

  // Helper method to get flash icon based on current mode
  IconData getFlashIcon() {
    if (!_flashAvailable) return Icons.flash_off;
    
    switch (getCurrentFlashMode()) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    super.dispose();
  }
}