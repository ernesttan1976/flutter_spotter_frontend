import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:spotter/features/reports/providers/report_provider.dart';
import 'package:spotter/features/reports/widgets/report_form.dart';
import 'package:spotter/shared/widgets/app_bar.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  @override
  void initState() {
    super.initState();
    // Start WOGAA transaction if needed
    // window.wogaaCustom?.startTransactionalService(wogaaTransactions.submitReport)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SpotterAppBar(title: 'Submit Report'),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Submit Report',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const ReportForm(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}