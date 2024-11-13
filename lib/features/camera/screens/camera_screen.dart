// lib/features/camera/screens/camera_screen.dart
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:spotter/features/camera/providers/camera_provider.dart';
import 'package:spotter/shared/widgets/app_bar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class CameraScreen extends StatefulWidget {
  final Function(File, String)? onMediaCaptured;

  const CameraScreen({
    super.key,
    this.onMediaCaptured,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  double _currentZoom = 1.0;
  bool _isRecording = false;
  bool _isProcessing = false;
  String _errorMessage = '';
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  static const int _maxRecordingDuration = 30; // seconds

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _recordingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    
    // Handle app lifecycle changes
    if (state == AppLifecycleState.inactive) {
      cameraProvider.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    try {
      await cameraProvider.initializeCamera();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize camera: $e';
      });
    }
  }

  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          _recordingDuration++;
        });
        
        if (_recordingDuration >= _maxRecordingDuration) {
          _handleMediaCapture();
        }
      },
    );
  }

  Future<void> _handleMediaCapture() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });

    try {
      final cameraProvider = Provider.of<CameraProvider>(context, listen: false);
      File? mediaFile;
      String mediaType;

      if (_isRecording) {
        // Stop video recording
        _recordingTimer?.cancel();
        mediaFile = await cameraProvider.recordVideo();
        mediaType = 'video';
        setState(() {
          _isRecording = false;
          _recordingDuration = 0;
        });
      } else {
        // Take photo
        mediaFile = await cameraProvider.takePhoto();
        mediaType = 'photo';
      }

      if (mediaFile != null) {
        // Process the media file (add watermark, etc.)
        final processedFile = await _processMediaFile(mediaFile, mediaType);
        
        // Call the callback with the processed file
        widget.onMediaCaptured?.call(processedFile, mediaType);
        
        // Optionally navigate back
        if (mounted) {
          Navigator.pop(context, {
            'file': processedFile,
            'type': mediaType,
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to capture media: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<File> _processMediaFile(File file, String type) async {
    final timestamp = DateTime.now().toIso8601String();
    final tempDir = await getTemporaryDirectory();
    
    if (type == 'photo') {
      // Process photo
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) throw Exception('Failed to decode image');

      // Add watermark
      final watermarkedImage = img.drawString(
        image,
        'SPOTTER $timestamp',
        font: img.arial24,
        color: img.ColorRgb8(255, 255, 255),
        x: 10,
        y: image.height - 30,
      );

      // Save processed image
      final processedFile = File(
        '${tempDir.path}/SPOT_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await processedFile.writeAsBytes(img.encodeJpg(watermarkedImage));
      
      // Delete original
      await file.delete();
      
      return processedFile;
    } else {
      // Process video
      // Note: For actual video processing, you'd want to use ffmpeg_kit_flutter
      // This is a simplified version that just copies the file
      final processedFile = File(
        '${tempDir.path}/SPOT_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );
      await file.copy(processedFile.path);
      
      // Delete original
      await file.delete();
      
      return processedFile;
    }
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CameraProvider>(
        builder: (context, cameraProvider, child) {
          if (!cameraProvider.isInitialized) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              // Camera Preview
              CameraPreview(cameraProvider.controller),

              // Error Message
              if (_errorMessage.isNotEmpty)
                Positioned(
                  top: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.withOpacity(0.8),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Recording Duration
              if (_isRecording)
                Positioned(
                  top: 60,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black54,
                    child: Text(
                      _formatDuration(_recordingDuration),
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              // Camera Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.black54,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Zoom Slider
                      Row(
                        children: [
                          const Icon(Icons.zoom_out, color: Colors.white),
                          Expanded(
                            child: Slider(
                              value: _currentZoom,
                              min: 1.0,
                              max: 5.0,
                              onChanged: (value) {
                                setState(() {
                                  _currentZoom = value;
                                  cameraProvider.setZoomLevel(value);
                                });
                              },
                            ),
                          ),
                          const Icon(Icons.zoom_in, color: Colors.white),
                        ],
                      ),

                      // Control Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Close Button
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: Colors.white,
                            onPressed: () => Navigator.pop(context),
                          ),

                          // Capture Button
                          GestureDetector(
                            onTapDown: (_) async {
                              if (!_isRecording) {
                                setState(() {
                                  _isRecording = true;
                                });
                                _startRecordingTimer();
                              } else {
                                await _handleMediaCapture();
                              }
                            },
                            child: Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 4,
                                ),
                                color: _isProcessing
                                    ? Colors.grey
                                    : (_isRecording ? Colors.red : Colors.white),
                              ),
                              child: _isProcessing
                                  ? const CircularProgressIndicator()
                                  : Icon(
                                      _isRecording
                                          ? Icons.stop
                                          : Icons.camera_alt,
                                      size: 40,
                                      color: _isRecording
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                            ),
                          ),

                          // Switch Camera Button
                          IconButton(
                            icon: const Icon(Icons.switch_camera),
                            color: Colors.white,
                            onPressed: cameraProvider.switchCamera,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}