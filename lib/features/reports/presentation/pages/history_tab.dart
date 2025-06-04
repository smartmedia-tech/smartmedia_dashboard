import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/bloc/reports_event.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/widgets/reports_list.dart';

class ReportsHistoryTab extends StatelessWidget {
  const ReportsHistoryTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        if (state is ReportsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ReportsLoaded) {
          return ReportsList(reports: state.reports);
        }

        if (state is ReportsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading reports',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ReportsBloc>().add(LoadReports());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const Center(child: Text('No reports available'));
      },
    );
  }
}
