import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/usecases/upload_image.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/bloc/campaign_bloc.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/bloc/campaign_event.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/bloc/campaign_state.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/pages/campaign_details_screen.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/widgets/campaign_card.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/widgets/campaign_form.dart';
import 'package:smartmedia_campaign_manager/injection_container.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  CampaignStatus? _statusFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CampaignBloc>().add(const LoadCampaigns());
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final state = context.read<CampaignBloc>().state;
      if (state is CampaignsLoaded && !state.hasReachedMax) {
        context.read<CampaignBloc>().add(LoadMoreCampaigns(
              limit: 10,
              lastId: state.lastId ?? '',
            ));
      }
    }
  }

  void _applyFilters() {
    context.read<CampaignBloc>().add(FilterCampaigns(
          searchQuery: _searchController.text,
          status: _statusFilter,
        ));
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _statusFilter = null;
    });
    context.read<CampaignBloc>().add(const LoadCampaigns());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildFilters(context),
            const SizedBox(height: 24),
            Expanded(child: _buildCampaignList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Campaigns',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showCreateDialog(),
          icon: const Icon(Icons.add),
          label: const Text('New Campaign'),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search campaigns...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
            ),
            onChanged: (_) => _applyFilters(),
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<CampaignStatus>(
          value: _statusFilter,
          hint: const Text('Filter by status'),
          items: CampaignStatus.values.map((status) {
            return DropdownMenuItem<CampaignStatus>(
              value: status,
              child: Text(status.name.toUpperCase()),
            );
          }).toList(),
          onChanged: (status) {
            setState(() => _statusFilter = status);
            _applyFilters();
          },
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: _clearFilters,
          child: const Text('Clear'),
        ),
      ],
    );
  }

  Widget _buildCampaignList() {
    return BlocBuilder<CampaignBloc, CampaignState>(
      builder: (context, state) {
        if (state is CampaignLoading && state.campaigns.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CampaignError && state.campaigns.isEmpty) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is CampaignsLoaded && state.campaigns.isEmpty) {
          return const Center(child: Text('No campaigns found'));
        }

        final campaigns = (state is CampaignsLoaded)
            ? (state).campaigns
            : (state is CampaignLoading)
                ? (state).campaigns
                : [];

        return GridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: campaigns.length + (state is CampaignLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= campaigns.length) {
              return const Center(child: CircularProgressIndicator());
            }
          return CampaignCard(
              campaign: campaigns[index],
              onTap: () => _navigateToDetails(context, campaigns[index]),
              onEdit: () => _showEditDialog(campaigns[index]),
              onDelete: () => _showDeleteConfirmation(campaigns[index].id),
            );
          },
        );
      },
    );
  }
void _showEditDialog(Campaign campaign) {
    showDialog(
      context: context,
      builder: (_) => CampaignFormDialog(
        campaign: campaign,
        onSubmit: (updatedCampaign, imageFile) async {
          if (imageFile != null) {
            try {
              final uploadCampaignImage = sl<UploadCampaignImage>();
              final imageUrl = await uploadCampaignImage(
                campaign.id,
                imageFile,
              );

              updatedCampaign = Campaign(
                id: updatedCampaign.id,
                name: updatedCampaign.name,
                description: updatedCampaign.description,
                startDate: updatedCampaign.startDate,
                endDate: updatedCampaign.endDate,
                status: updatedCampaign.status,
                clientId: updatedCampaign.clientId,
                clientLogoUrl: imageUrl,
              );
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to upload image: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          }

          context.read<CampaignBloc>().add(UpdateCampaign(updatedCampaign));
        },
      ),
    );
  }


  void _showDeleteConfirmation(String campaignId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: const Text('Are you sure you want to delete this campaign?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CampaignBloc>().add(DeleteCampaign(campaignId));
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  void _navigateToDetails(BuildContext context, CampaignEntity campaign) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CampaignDetailsScreen(campaign: campaign),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => CampaignFormDialog(
        onSubmit: (campaign, imageFile) async {
          if (imageFile != null) {
            try {
              // Generate a temporary ID for new campaigns
              final tempId = DateTime.now().millisecondsSinceEpoch.toString();

              // Get the use case from the dependency injection system
              final uploadCampaignImage = sl<UploadCampaignImage>();

              // Upload the image and get URL
              final imageUrl = await uploadCampaignImage(tempId, imageFile);

              // Update campaign with image URL
              campaign = Campaign(
                id: campaign.id,
                name: campaign.name,
                description: campaign.description,
                startDate: campaign.startDate,
                endDate: campaign.endDate,
                status: campaign.status,
                clientId: campaign.clientId,
                clientLogoUrl: imageUrl,
              );
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to upload image: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
              // Continue with the campaign creation even if image upload fails
            }
          }

          // Add campaign to bloc
          context.read<CampaignBloc>().add(AddCampaign(campaign));
        },
      ),
    );
  }



  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
