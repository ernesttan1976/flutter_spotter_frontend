// lib/features/reports/widgets/report_table.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotter/features/reports/providers/report_provider.dart';
import 'package:spotter/features/reports/models/report.dart';
import 'package:spotter/config/routes.dart';
import 'package:intl/intl.dart';

class ReportTable extends StatelessWidget {
  const ReportTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        if (reportProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (reportProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${reportProvider.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: reportProvider.fetchReports,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (reportProvider.reports.isEmpty) {
          return const Center(
            child: Text('No reports found'),
          );
        }

        return _ReportDataTable(reports: reportProvider.reports);
      },
    );
  }
}

class _ReportDataTable extends StatefulWidget {
  final List<Report> reports;

  const _ReportDataTable({required this.reports});

  @override
  State<_ReportDataTable> createState() => _ReportDataTableState();
}

class _ReportDataTableState extends State<_ReportDataTable> {
  int _currentPage = 0;
  static const int _rowsPerPage = 10;
  final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  List<Report> get _paginatedReports {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = (startIndex + _rowsPerPage).clamp(0, widget.reports.length);
    return widget.reports.sublist(startIndex, endIndex);
  }

  int get _pageCount => (widget.reports.length / _rowsPerPage).ceil();

  void _navigateToEditReport(Report report) {
    Navigator.pushNamed(
      context,
      Routes.editReport,
      arguments: {
        'reportId': report.id,
        'defaultLocation': [report.latitude, report.longitude],
        'defaultBearing': report.bearing,
        'defaultRemarks': report.remarks,
        'defaultPhoto': report.photoUrl,
        'reportTime': report.createdAt,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Time sent')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Bearing')),
                  DataColumn(label: Text('Media')),
                  DataColumn(label: Text('Remarks')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _paginatedReports.map((report) {
                  return DataRow(
                    cells: [
                      DataCell(Text(dateFormat.format(report.createdAt))),
                      DataCell(Text(
                        '${report.latitude.toStringAsFixed(6)}, '
                        '${report.longitude.toStringAsFixed(6)}',
                      )),
                      DataCell(Text(
                        report.bearing?.toStringAsFixed(2) ?? 'N/A',
                      )),
                      DataCell(
                        report.photoUrl != null
                            ? IconButton(
                                icon: const Icon(Icons.image),
                                onPressed: () => _showMediaPreview(report),
                              )
                            : const Text('-'),
                      ),
                      DataCell(
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 200),
                          child: Text(
                            report.remarks ?? '-',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        onTap: () {
                          if (report.remarks?.isNotEmpty ?? false) {
                            _showRemarksDialog(report);
                          }
                        },
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToEditReport(report),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        _buildPagination(),
      ],
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0
                ? () => setState(() => _currentPage--)
                : null,
          ),
          Text(
            'Page ${_currentPage + 1} of $_pageCount',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentPage < _pageCount - 1
                ? () => setState(() => _currentPage++)
                : null,
          ),
        ],
      ),
    );
  }

  void _showMediaPreview(Report report) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Media Preview'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                report.photoUrl!,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.error_outline, size: 48, color: Colors.red),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemarksDialog(Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remarks'),
        content: SingleChildScrollView(
          child: Text(report.remarks ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Optional: Create a custom TableHeader widget for better styling
class _TableHeader extends StatelessWidget {
  final String text;
  final bool sortable;
  final bool sorted;
  final bool ascending;
  final VoidCallback? onSort;

  const _TableHeader({
    required this.text,
    this.sortable = false,
    this.sorted = false,
    this.ascending = true,
    this.onSort,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        if (sortable) ...[
          const SizedBox(width: 4),
          Icon(
            sorted
                ? (ascending ? Icons.arrow_upward : Icons.arrow_downward)
                : Icons.sort,
            size: 16,
          ),
        ],
      ],
    );
  }
}

// Optional: Create a custom shimmer loading effect for the table
class _TableShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: List.generate(
              6,
              (index) => Expanded(
                child: Container(
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}