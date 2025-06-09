import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';
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

          return DropdownButtonFormField<CampaignEntity>(
            decoration: const InputDecoration(
              labelText: 'Select Campaign',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.campaign),
            ),
            items: campaigns.map((campaign) {
              return DropdownMenuItem<CampaignEntity>(
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
                context.read<ReportsBloc>().add(SelectCampaign(campaign as Campaign));
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
