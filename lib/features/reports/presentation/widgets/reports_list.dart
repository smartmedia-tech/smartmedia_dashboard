import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/widgets/report_detail_dialog.dart';
import '../../domain/entities/report.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';

class ReportsList extends StatelessWidget {
  final List<Report> reports;

  const ReportsList({Key? key, required this.reports}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No reports generated yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Generate your first report by selecting a campaign',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final report = reports[index];
        return ReportCard(
          report: report,
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ReportDetailDialog(report: report),
            );
          },
          onDelete: () {
            _showDeleteConfirmation(context, report);
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Report report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: Text(
          'Are you sure you want to delete the report for "${report.campaign.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ReportsBloc>().add(DeleteReport(report.id));
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReportCard({
    Key? key,
    required this.report,
    required this.onTap,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.campaign.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Generated on ${_formatDate(report.generatedAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetricChip(
                    icon: Icons.store,
                    label: '${report.metrics.totalStores} stores',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _MetricChip(
                    icon: Icons.point_of_sale,
                    label: '${report.metrics.totalTills} tills',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _MetricChip(
                    icon: Icons.analytics,
                    label:
                        '${report.metrics.occupancyRate.toStringAsFixed(1)}%',
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: _getStatusColor(report.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getStatusIcon(report.status),
                      size: 12,
                      color: _getStatusColor(report.status),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getStatusText(report.status),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getStatusColor(report.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.completed:
        return Colors.green;
      case ReportStatus.generating:
        return Colors.orange;
      case ReportStatus.failed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ReportStatus status) {
    switch (status) {
      case ReportStatus.completed:
        return Icons.check_circle;
      case ReportStatus.generating:
        return Icons.hourglass_empty;
      case ReportStatus.failed:
        return Icons.error;
    }
  }

  String _getStatusText(ReportStatus status) {
    switch (status) {
      case ReportStatus.completed:
        return 'Completed';
      case ReportStatus.generating:
        return 'Generating';
      case ReportStatus.failed:
        return 'Failed';
    }
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
