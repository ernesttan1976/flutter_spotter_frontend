import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraService {
  CameraController? _controller;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Request camera permission
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      throw Exception('Camera permission denied');
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: true,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
    _isInitialized = true;
  }

  Future<void> setResolution(ResolutionPreset resolution) async {
    if (!_isInitialized || _controller == null) return;

    final cameras = await availableCameras();
    final oldController = _controller;
    
    _controller = CameraController(
      cameras.first,
      resolution,
      enableAudio: oldController!.value.isRecordingVideo,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await oldController.dispose();
    await _controller!.initialize();
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
      // Capture image
      final XFile photo = await _controller!.takePicture();
      
      // Add watermark
      final watermarkedImage = await _addWatermark(File(photo.path));
      
      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await watermarkedImage.writeAsBytes(await watermarkedImage.readAsBytes());
      
      // Delete original
      await File(photo.path).delete();
      
      return watermarkedImage;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  Future<File> startVideoRecording() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (_controller!.value.isRecordingVideo) {
      throw Exception('Already recording video');
    }

    try {
      await _controller!.startVideoRecording();
      return await stopVideoRecording();
    } catch (e) {
      throw Exception('Failed to record video: $e');
    }
  }

  Future<File> stopVideoRecording() async {
    if (!_isInitialized || _controller == null) {
      throw Exception('Camera not initialized');
    }

    if (!_controller!.value.isRecordingVideo) {
      throw Exception('Not recording video');
    }

    try {
      final XFile videoFile = await _controller!.stopVideoRecording();
      final watermarkedVideo = await _addVideoWatermark(File(videoFile.path));
      
      // Delete original
      await File(videoFile.path).delete();
      
      return watermarkedVideo;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  Future<File> _addWatermark(File imageFile) async {
    // Read the image
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes);
    
    if (image == null) throw Exception('Failed to decode image');

    // Create watermark text
    final watermark = img.drawString(
      image,
      'SPOTTER ${DateTime.now().toString()}',
      font: img.arial24,
      color: img.ColorRgb8(255, 255, 255),
      x: 10,
      y: image.height - 30,
    );

    // Save the watermarked image
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final watermarkedFile = File(tempPath);
    await watermarkedFile.writeAsBytes(img.encodeJpg(watermark));

    return watermarkedFile;
  }

  Future<File> _addVideoWatermark(File videoFile) async {
    // For video watermarking, you might want to use ffmpeg_kit_flutter
    // This is a simplified version that just returns the original file
    // TODO: Implement actual video watermarking
    return videoFile;
  }

  void dispose() {
    _controller?.dispose();
    _isInitialized = false;
  }
}