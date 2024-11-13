// lib/features/reports/widgets/media_capture_section.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:spotter/config/routes.dart';

class MediaCaptureSection extends StatelessWidget {
  final File? mediaFile;
  final String? mediaType;
  final Function(File, String) onMediaCaptured;

  const MediaCaptureSection({
    super.key,
    this.mediaFile,
    this.mediaType,
    required this.onMediaCaptured,
  });

  Future<void> _openCamera(BuildContext context) async {
    try {
      final result = await Navigator.pushNamed(
        context,
        Routes.camera,
      );

      if (result != null && result is Map<String, dynamic>) {
        final file = result['file'] as File;
        final type = result['type'] as String;
        onMediaCaptured(file, type);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture media: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Capture Button
        ElevatedButton.icon(
          onPressed: () => _openCamera(context),
          icon: const Icon(Icons.camera_alt),
          label: const Text('Capture Media'),
        ),

        // Media Preview
        if (mediaFile != null) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Captured ${mediaType ?? "media"}:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (mediaType == 'photo')
                    Image.file(
                      mediaFile!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else if (mediaType == 'video')
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.black87,
                      child: const Center(
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'File: ${mediaFile!.path.split('/').last}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _openCamera(context),
                        icon: const Icon(Icons.replay),
                        label: const Text('Retake'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
