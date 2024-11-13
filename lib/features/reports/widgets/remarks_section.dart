// lib/features/reports/widgets/remarks_section.dart
import 'package:flutter/material.dart';

class RemarksSection extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;

  const RemarksSection({
    super.key,
    required this.controller,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      maxLength: 255,
      decoration: InputDecoration(
        labelText: 'Remarks',
        hintText: 'Enter additional details (optional)',
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}