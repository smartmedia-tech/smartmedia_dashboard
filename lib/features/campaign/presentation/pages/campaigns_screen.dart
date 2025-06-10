import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign_entity.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/bloc/campaign_bloc.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/bloc/campaign_event.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/bloc/campaign_state.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/pages/campaign_details_screen.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/widgets/campaign_card.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/widgets/campaign_form.dart';

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
          onPressed: () => _showCreateDialog(context),
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
            );
          },
        );
      },
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

void _showCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => CampaignFormDialog(
        onSubmit: (campaign, imageFile) async {
          // Handle the form submission here
          try {
            // Example implementation:
            // 1. Create/update campaign in your backend
            // 2. Upload image if new file was selected
            // 3. Refresh your campaign list

            // This would call your actual campaign creation/update logic
            // final result = await _campaignRepository.createCampaign(campaign, imageFile);

            // Show success feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(campaign.id.isEmpty
                    ? 'Campaign created successfully!'
                    : 'Campaign updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Optionally refresh data in parent widget
            // if (mounted) setState(() {});
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
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
