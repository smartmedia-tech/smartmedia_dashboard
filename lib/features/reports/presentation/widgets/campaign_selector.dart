// lib/features/reports/presentation/widgets/campaign_selector.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/bloc/campaign_bloc.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/bloc/campaign_state.dart';

import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';

class CampaignSelector extends StatelessWidget {
  const CampaignSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CampaignBloc, CampaignState>(
      builder: (context, state) {
        if (state is CampaignsLoaded) {
          final campaigns = state.campaigns;
          if (campaigns.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No campaigns available. Please create a campaign first.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                ],
              ),
            );
          }

          final currentReportsState = context.watch<ReportsBloc>().state;
          Campaign? selectedCampaign;
          if (currentReportsState is ReportsLoaded) {
            selectedCampaign = currentReportsState.selectedCampaign;
          }

          return DropdownButtonFormField<Campaign>(
            decoration: InputDecoration(
              labelText: 'Select Campaign',
              hintText: 'Choose a campaign for the report',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              prefixIcon:
                  Icon(Icons.campaign, color: Theme.of(context).primaryColor),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12), // Adjusted padding
            ),
            value: selectedCampaign,
            items: campaigns.map((campaignEntity) {
              final campaign = campaignEntity as Campaign;
              return DropdownMenuItem<Campaign>(
                value: campaign,
                child: Text(
                  '${campaign.name} - ${campaign.description}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500, color: Color(0xFF333333)),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }).toList(),
            onChanged: (campaign) {
              if (campaign != null) {
                context.read<ReportsBloc>().add(SelectCampaign(campaign));
              }
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a campaign';
              }
              return null;
            },
          );
        }

        if (state is CampaignLoading) {
          return const LinearProgressIndicator(
            backgroundColor: Colors.blueGrey,
            color: Colors.blueAccent,
          );
        }

        // Generic error/empty state for campaign selector
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error loading campaigns. Please check your connection.',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
