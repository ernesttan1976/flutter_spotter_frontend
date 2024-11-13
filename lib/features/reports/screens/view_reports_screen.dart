import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotter/features/reports/providers/report_provider.dart';
import 'package:spotter/features/reports/widgets/report_table.dart';
import 'package:spotter/shared/widgets/app_bar.dart';

class ViewReportsScreen extends StatefulWidget {
  const ViewReportsScreen({super.key});

  @override
  State<ViewReportsScreen> createState() => _ViewReportsScreenState();
}

class _ViewReportsScreenState extends State<ViewReportsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch reports when screen loads
    context.read<ReportProvider>().fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SpotterAppBar(title: 'View Reports'),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'View Reports',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const Expanded(child: ReportTable()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}