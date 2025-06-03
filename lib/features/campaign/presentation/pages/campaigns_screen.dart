import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/usecases/upload_image.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/widgets/campaign_form.dart';
import 'package:smartmedia_campaign_manager/injection_container.dart';
import '../bloc/campaign_bloc.dart';
import '../bloc/campaign_event.dart';
import '../bloc/campaign_state.dart';
import '../../domain/entities/campaign.dart';
import '../widgets/campaign_card.dart';
import '../widgets/empty_campaigns_placeholder.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final List<String> _statusOptions = [
    'All',
    'Active',
    'Pending',
    'Completed',
    'Paused'
  ];
  String _selectedStatus = 'All';
  bool _isSearchExpanded = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load campaigns only once when the widget is first built
    if (!_isInitialized) {
      final state = context.read<CampaignBloc>().state;
      // Only load campaigns if they haven't been loaded already or if there was an error
      if (state is! CampaignsLoaded || state.campaigns.isEmpty) {
        context.read<CampaignBloc>().add(const LoadCampaigns());
      }
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
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
    // Convert selected string status to enum
    CampaignStatus? statusFilter;
    if (_selectedStatus != 'All') {
      statusFilter = CampaignStatus.values.firstWhere(
        (e) => e.toString().split('.').last == _selectedStatus,
        orElse: () => CampaignStatus.values.first,
      );
    }

    context.read<CampaignBloc>().add(
          FilterCampaigns(
            searchQuery: _searchController.text,
            status: statusFilter,
          ),
        );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = 'All';
    });
    context.read<CampaignBloc>().add(const LoadCampaigns());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header and Search Bar
          _buildHeaderWithSearch(theme),

          // Filter Chips
          _buildFilterChips(theme),

          // Campaign Grid View
          Expanded(
            child: _buildCampaignGridView(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderWithSearch(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Campaigns',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              // Search Field
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _isSearchExpanded ? 240 : 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: Icon(
                          _isSearchExpanded ? Icons.close : Icons.search,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          setState(() {
                            _isSearchExpanded = !_isSearchExpanded;
                            if (!_isSearchExpanded) {
                              _searchController.clear();
                              _applyFilters();
                            }
                          });
                        },
                        splashRadius: 20,
                      ),
                    ),
                    if (_isSearchExpanded)
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search campaigns...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7),
                            ),
                          ),
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          onChanged: (_) => _applyFilters(),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Refresh Button
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () =>
                      context.read<CampaignBloc>().add(const LoadCampaigns()),
                  tooltip: 'Refresh Campaigns',
                  splashRadius: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Add Campaign Button
              ElevatedButton.icon(
                onPressed: () => _showCreateDialog(),
                icon: const Icon(Icons.add),
                label: const Text('New Campaign'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        children: [
          Text(
            'Filter by: ',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _statusOptions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final status = _statusOptions[index];
                  final isSelected = status == _selectedStatus;

                  return ChoiceChip(
                    label: Text(status),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedStatus = status;
                        });
                        _applyFilters();
                      }
                    },
                    selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: _clearFilters,
            icon: Icon(
              Icons.tune_outlined,
              size: 18,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              'Clear',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignGridView() {
    return BlocConsumer<CampaignBloc, CampaignState>(
      listener: (context, state) {
        if (state is CampaignError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CampaignOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is CampaignLoading && state.campaigns.isEmpty) {
          return const LoadingIndicator(itemCount: 6);
        } else if (state is CampaignError && state.campaigns.isEmpty) {
          return ErrorDisplay(
            message: state.message,
            onRetry: () =>
                context.read<CampaignBloc>().add(const LoadCampaigns()),
          );
        } else if (state is CampaignsLoaded && state.campaigns.isEmpty) {
          return const EmptyCampaignsPlaceholder();
        }

        // Handle states with data
        List<Campaign> campaigns = [];
        bool isLoadingMore = false;
        bool hasReachedMax = false;

        if (state is CampaignLoading) {
          campaigns = state.campaigns;
          isLoadingMore = true;
        } else if (state is CampaignError) {
          campaigns = state.campaigns;
        } else if (state is CampaignsLoaded) {
          campaigns = state.campaigns;
          hasReachedMax = state.hasReachedMax;
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 350,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => CampaignCard(
                      campaign: campaigns[index],
                      onDelete: (id) => _showDeleteConfirmation(id),
                      onEdit: (campaign) => _showEditDialog(campaign),
                     onViewDetails: (campaign) {
                        // Navigator.push(
                          // context,
                          // MaterialPageRoute(
                          //   builder: (context) =>
                          //       CampaignDetailsScreen(campaign: campaign),
                          // ),
                        // );
                      },
                    ),
                    childCount: campaigns.length,
                  ),
                ),
              ),
              if (isLoadingMore)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              if (hasReachedMax && campaigns.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No more campaigns to load',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
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

  void _showEditDialog(Campaign campaign) {
    showDialog(
      context: context,
      builder: (_) => CampaignFormDialog(
        campaign: campaign,
        onSubmit: (updatedCampaign, imageFile) async {
          if (imageFile != null) {
            try {
              // Get the use case from the dependency injection system
              final uploadCampaignImage = sl<UploadCampaignImage>();

              // Use the existing campaign ID for the image
              final imageUrl = await uploadCampaignImage(
                campaign.id,
                imageFile,
              );

              // Update campaign with the new image URL
              updatedCampaign = Campaign(
                id: updatedCampaign.id,
                name: updatedCampaign.name,
                description: updatedCampaign.description,
                startDate: updatedCampaign.startDate,
                endDate: updatedCampaign.endDate,
                status: updatedCampaign.status,
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

          // Update campaign in bloc
          context.read<CampaignBloc>().add(UpdateCampaign(updatedCampaign));
        },
      ),
    );
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text('Delete Campaign'),
        content: const Text('Are you sure you want to delete this campaign?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CampaignBloc>().add(DeleteCampaign(id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
