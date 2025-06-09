// lib/features/reports/presentation/pages/history_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/bloc/reports_event.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/widgets/reports_list.dart'; // Renamed from reports_list.dart for better naming

class ReportsHistoryTab extends StatefulWidget { // Changed to StatefulWidget to manage filters
  const ReportsHistoryTab({Key? key}) : super(key: key);

  @override
  State<ReportsHistoryTab> createState() => _ReportsHistoryTabState();
}

class _ReportsHistoryTabState extends State<ReportsHistoryTab> {
  String? _selectedFilterStatus; // For filtering reports

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReportsLoaded) {
          // Apply filters based on _selectedFilterStatus
          final filteredReports = state.reports.where((report) {
            if (_selectedFilterStatus == null || _selectedFilterStatus == 'All') {
              return true;
            }
            return report.status.name.toLowerCase() == _selectedFilterStatus!.toLowerCase();
          }).toList();

          return Column(
            children: [
              // Filters and Search Bar for Reports History
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search reports by campaign name...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        onChanged: (query) {
                          // TODO: Implement actual search logic in BLoC or filter here
                          // For now, this is just a UI placeholder
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Status Filter Dropdown
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilterStatus ?? 'All',
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedFilterStatus = newValue;
                          });
                        },
                        items: const <String>['All', 'Completed', 'Generating', 'Failed']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        style: const TextStyle(color: Colors.black87, fontSize: 16),
                        icon: const Icon(Icons.filter_list, color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        dropdownColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ReportsList(reports: filteredReports), // Pass filtered reports
              ),
            ],
          );
        }

        if (state is ReportsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading reports',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.red[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<ReportsBloc>().add(LoadReports());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          );
        }

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
                'No reports available',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Generate your first report in the "Generate Report" tab.',
                style: TextStyle(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}