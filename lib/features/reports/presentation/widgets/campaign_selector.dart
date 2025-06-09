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
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No campaigns available. Create a campaign first.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }

          // Get the currently selected campaign from ReportsBloc state for initial value
          final currentReportsState = context.watch<ReportsBloc>().state;
          Campaign? selectedCampaign;
          if (currentReportsState is ReportsLoaded) {
            selectedCampaign = currentReportsState.selectedCampaign;
          }

          return DropdownButtonFormField<Campaign>(
            // Use Campaign directly
            decoration: const InputDecoration(
              labelText: 'Select Campaign',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.campaign),
            ),
            value: selectedCampaign, // Set initial value
            items: campaigns.map((campaignEntity) {
              // Cast CampaignEntity to Campaign if Campaign is a concrete implementation
              // or ensure your CampaignsLoaded state returns Campaign objects.
              final campaign = campaignEntity as Campaign;
              return DropdownMenuItem<Campaign>(
                value: campaign,
                child: Text(
                  '${campaign.name} - ${campaign.description}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
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
          return const LinearProgressIndicator();
        }

        return const Text('Error loading campaigns');
      },
    );
  }
}
