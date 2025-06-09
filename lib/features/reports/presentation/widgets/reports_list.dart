// lib/features/reports/presentation/widgets/reports_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/widgets/report_detail_dialog.dart';
import '../../domain/entities/report.dart'; // Make sure Report is imported
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';

class ReportsList extends StatelessWidget {
  final List<Report> reports;

  const ReportsList({Key? key, required this.reports}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'No reports found matching your criteria.',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters or generate a new report.',
              style: TextStyle(
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      // Changed from ListView to GridView for dashboard look
      padding:
          const EdgeInsets.all(0), // Padding is now handled by DashboardLayout
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400.0, // Max width of each card
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        childAspectRatio: 2.0, // Adjust as needed to control card height
      ),
      itemCount: reports.length,
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
        title: const Text('Delete Report', style: TextStyle(color: Colors.red)),
        content: Text(
          'Are you sure you want to delete the report for "${report.campaign.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            // Changed to ElevatedButton for prominence
            onPressed: () {
              context.read<ReportsBloc>().add(DeleteReport(report.id));
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
      elevation: 4, // Increased elevation for a richer look
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)), // More rounded corners
      clipBehavior: Clip.antiAlias, // Ensures content respects border radius
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20), // Increased padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align top
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.campaign.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context)
                                .primaryColor, // Use primary color
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Generated on ${_formatDate(report.generatedAt)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        onDelete();
                      } else if (value == 'view_detail') {
                        onTap(); // Direct view option
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view_detail',
                        child: Row(
                          children: [
                            Icon(Icons.visibility,
                                color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Delete Report'),
                          ],
                        ),
                      ),
                    ],
                    icon: Icon(Icons.more_vert,
                        color: Colors.grey[700]), // More subtle icon
                  ),
                ],
              ),
              const Spacer(), // Pushes content to top/bottom
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Distribute chips
                children: [
                  _MetricChip(
                    icon: Icons.store,
                    label: '${report.metrics.totalStores} stores',
                    color: Colors.blue,
                  ),
                  _MetricChip(
                    icon: Icons.point_of_sale,
                    label: '${report.metrics.totalTills} tills',
                    color: Colors.green,
                  ),
                  _MetricChip(
                    icon: Icons.analytics,
                    label:
                        '${report.metrics.occupancyRate.toStringAsFixed(1)}%',
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Align(
                // Status chip aligned to the left
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                  decoration: BoxDecoration(
                    color: _getStatusColor(report.status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Wrap content tightly
                    children: [
                      Icon(
                        _getStatusIcon(report.status),
                        size: 14,
                        color: _getStatusColor(report.status),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getStatusText(report.status),
                        style: TextStyle(
                          fontSize: 12,
                          color: _getStatusColor(report.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    // A more readable date format
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // (Status color, icon, text methods remain the same)
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
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 6), // Slightly larger padding
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), // Slightly more opaque background
        borderRadius: BorderRadius.circular(16), // More rounded corners
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color), // Slightly larger icon
          const SizedBox(width: 6), // Slightly more spacing
          Text(
            label,
            style: TextStyle(
              fontSize: 12, // Slightly larger font
              color: color,
              fontWeight: FontWeight.w600, // Slightly bolder font
            ),
          ),
        ],
      ),
    );
  }
}
