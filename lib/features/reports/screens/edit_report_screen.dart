import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:spotter/features/reports/providers/report_provider.dart';
import 'package:spotter/features/reports/widgets/report_form.dart';
import 'package:spotter/shared/widgets/app_bar.dart';
// import 'package:spotter/features/reports/models/report.dart';

class EditReportScreen extends StatefulWidget {
  final String? reportId;
  final List<double>? defaultLocation;
  final double? defaultBearing;
  final String? defaultRemarks;
  final String? defaultPhoto;
  final DateTime? reportTime;

  const EditReportScreen({
    super.key,
    this.reportId,
    this.defaultLocation,
    this.defaultBearing,
    this.defaultRemarks,
    this.defaultPhoto,
    this.reportTime,
  });

  @override
  State<EditReportScreen> createState() => _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.reportId == null) {
      // Handle invalid report case
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: editing invalid report')),
        );
        Navigator.pushReplacementNamed(context, '/view');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: const SpotterAppBar(title: 'Edit Report'),
      body: Container(
        color: Theme.of(context).colorScheme.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit Report',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (widget.reportTime != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Currently editing report sent at ${_formatDateTime(widget.reportTime!)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 16),
                  ReportForm(
                    reportId: widget.reportId,
                    defaultLocation: widget.defaultLocation,
                    defaultBearing: widget.defaultBearing,
                    defaultRemarks: widget.defaultRemarks,
                    defaultPhoto: widget.defaultPhoto,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}