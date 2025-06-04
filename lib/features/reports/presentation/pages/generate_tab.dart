import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/bloc/reports_event.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/widgets/campaign_selector.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/widgets/report_preview.dart';

class GenerateReportTab extends StatelessWidget {
  const GenerateReportTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReportsBloc, ReportsState>(
      listener: (context, state) {
        if (state is ReportGenerated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report generated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReportsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReportsLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Campaign',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const CampaignSelector(),
                          if (state.selectedCampaign != null) ...[
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: state.isGeneratingReport
                                  ? null
                                  : () {
                                      context.read<ReportsBloc>().add(
                                            GenerateReport(
                                                state.selectedCampaign!),
                                          );
                                    },
                              icon: state.isGeneratingReport
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.analytics),
                              label: Text(
                                state.isGeneratingReport
                                    ? 'Generating...'
                                    : 'Generate Report',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (state.selectedCampaign != null &&
                      state.campaignStores.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    ReportPreview(
                      campaign: state.selectedCampaign!,
                      stores: state.campaignStores,
                    ),
                  ],
                ],
              ),
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }
}
