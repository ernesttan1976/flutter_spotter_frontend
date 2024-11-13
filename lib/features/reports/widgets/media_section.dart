// lib/features/reports/widgets/media_section.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaSection extends StatelessWidget {
  final XFile? mediaFile;
  final Function(XFile) onMediaSelected;
  final String? existingMediaUrl;

  const MediaSection({
    super.key,
    this.mediaFile,
    required this.onMediaSelected,
    this.existingMediaUrl,
  });

  Future<void> _pickMedia(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? media = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (media != null) {
        onMediaSelected(media);
      }
    } catch (e) {
      debugPrint('Error picking media: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickMedia(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickMedia(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose Existing'),
              ),
            ),
          ],
        ),
        if (mediaFile != null) ...[
          const SizedBox(height: 8),
          Text(
            'Selected: ${mediaFile!.name}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        if (existingMediaUrl != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () {
              // Implement media preview
            },
            icon: const Icon(Icons.image),
            label: const Text('View Existing Media'),
          ),
        ],
      ],
    );
  }
}