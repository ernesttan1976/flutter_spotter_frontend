// lib/features/reports/widgets/report_form.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:spotter/features/reports/providers/report_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spotter/features/reports/widgets/media_capture_section.dart';
import 'dart:io';

class ReportForm extends StatefulWidget {
  final String? reportId;
  final List<double>? defaultLocation;
  final double? defaultBearing;
  final String? defaultRemarks;
  final String? defaultPhoto;

  const ReportForm({
    super.key,
    this.reportId,
    this.defaultLocation,
    this.defaultBearing,
    this.defaultRemarks,
    this.defaultPhoto,
  });

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _formKey = GlobalKey<FormState>();
  final _remarksController = TextEditingController();
  bool _isSubmitting = false;
  bool _isPinned = false;
  LatLng? _location;
  double? _bearing;
  File? _mediaFile;
  String? _mediaType;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.defaultRemarks != null) {
      _remarksController.text = widget.defaultRemarks!;
    }
    if (widget.defaultLocation != null) {
      _location = LatLng(
        widget.defaultLocation![0],
        widget.defaultLocation![1],
      );
    }
    if (widget.defaultBearing != null) {
      _bearing = widget.defaultBearing!;
      _isPinned = true;
    }
  }

  void _handleMediaCapture(File file, String type) {
    setState(() {
      _mediaFile = file;
      _mediaType = type;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _location == null || _bearing == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final reportProvider = context.read<ReportProvider>();
      final formData = {
        'latitude': _location!.latitude,
        'longitude': _location!.longitude,
        'bearing': _bearing,
        'remarks': _remarksController.text,
      };

      // Handle media upload if available
      if (_mediaFile != null) {
        // Handle media upload
        print('Uploading media: ${_mediaFile!.path} (${_mediaType})');
      }

      bool success;
      if (widget.reportId != null) {
        success = await reportProvider.editReport(widget.reportId!, formData);
      } else {
        success = await reportProvider.sendReport(formData);
      }

      if (!mounted) return;

      if (success && _mediaFile != null) {
        // Handle media upload
        final mediaFormData = FormData.fromMap({
          'media': await MultipartFile.fromFile(_mediaFile!.path),
        });
        
        await reportProvider.uploadMedia(widget.reportId ?? 'new', mediaFormData);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image != null) {
        setState(() => _mediaFile = image as File?);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Location and Bearing Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location and Bearing',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  
                  // Map
                  SizedBox(
                    height: 200,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _location ?? const LatLng(1.3521, 103.8198),
                        zoom: 15,
                      ),
                      onCameraMove: (position) {
                        if (!_isPinned) {
                          setState(() => _location = position.target);
                        }
                      },
                      markers: _location == null
                          ? {}
                          : {
                              Marker(
                                markerId: const MarkerId('location'),
                                position: _location!,
                              ),
                            },
                    ),
                  ),
                  
                  // Bearing Button
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isPinned
                        ? () {
                            setState(() => _isPinned = false);
                          }
                        : () {
                            // Implement bearing detection
                            setState(() {
                              _bearing = 45.0; // Example value
                              _isPinned = true;
                            });
                          },
                    icon: Icon(_isPinned ? Icons.lock_open : Icons.lock),
                    label: Text(_isPinned ? 'Unpin Location' : 'Pin Location'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Media Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Media',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                        ),
                      ),
                    ],
                  ),
                  if (_mediaFile != null) ...[
                    const SizedBox(height: 8),
                    Text('Media selected: ${_mediaFile!.path}'),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Media Capture Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Media',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  MediaCaptureSection(
                    mediaFile: _mediaFile,
                    mediaType: _mediaType,
                    onMediaCaptured: _handleMediaCapture,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Remarks Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Remarks',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _remarksController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter remarks (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }
}