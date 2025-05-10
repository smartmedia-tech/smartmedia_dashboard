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
  final _statusFilterController = TextEditingController();
  CampaignStatus? _filterStatus;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<CampaignBloc>().add(const LoadCampaigns());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _statusFilterController.dispose();
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
    // context.read<CampaignBloc>().add(FilterCampaigns(
    //       searchQuery: _searchController.text.trim(),
    //       status: _filterStatus,
    //     ));
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _filterStatus = null;
      _statusFilterController.clear();
      _showFilters = false;
    });
    context.read<CampaignBloc>().add(const LoadCampaigns());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header with search and filter
          _buildHeader(context),
          // Campaign list
          Expanded(
            child: BlocConsumer<CampaignBloc, CampaignState>(
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
                  return const Center(child: LoadingIndicator(itemCount: 4));
                } else if (state is CampaignError && state.campaigns.isEmpty) {
                  return Center(
                    child: ErrorDisplay(
                      message: state.message,
                      onRetry: () =>
                          context.read<CampaignBloc>().add(const LoadCampaigns()),
                    ),
                  );
                } else if (state is CampaignsLoaded &&
                    state.campaigns.isEmpty) {
                  return const Center(child: EmptyCampaignsPlaceholder());
                }

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

                return _buildCampaignList(
                  context,
                  campaigns,
                  isLoadingMore,
                  hasReachedMax,
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search campaigns...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (_) => _applyFilters(),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  setState(() => _showFilters = !_showFilters);
                },
                tooltip: 'Filters',
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  _clearFilters();
                },
                tooltip: 'Refresh',
              ),
            ],
          ),
          if (_showFilters) ...[
            const SizedBox(height: 12),
            _buildFilterSection(),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Campaigns',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${_getCampaignCount(context)} items',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        SizedBox(
          width: 200,
          child: DropdownMenu<CampaignStatus>(
            controller: _statusFilterController,
            initialSelection: _filterStatus,
            onSelected: (status) {
              setState(() => _filterStatus = status);
              _applyFilters();
            },
            dropdownMenuEntries: CampaignStatus.values
                .map(
                  (status) => DropdownMenuEntry<CampaignStatus>(
                    value: status,
                    label: status.toString().split('.').last,
                  ),
                )
                .toList(),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            label: const Text('Status'),
          ),
        ),
        if (_filterStatus != null)
          ActionChip(
            label: const Text('Clear status'),
            onPressed: () {
              setState(() => _filterStatus = null);
              _statusFilterController.clear();
              _applyFilters();
            },
            avatar: const Icon(Icons.close, size: 16),
          ),
      ],
    );
  }

  Widget _buildCampaignList(
    BuildContext context,
    List<Campaign> campaigns,
    bool isLoadingMore,
    bool hasReachedMax,
  ) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 360,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => CampaignCard(
                campaign: campaigns[index],
                onDelete: (id) => _showDeleteConfirmation(id),
                onEdit: (campaign) => _showEditDialog(campaign),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'You\'ve reached the end',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
      ],
    );
  }

  int _getCampaignCount(BuildContext context) {
    final state = context.read<CampaignBloc>().state;
    if (state is CampaignsLoaded) {
      return state.campaigns.length;
    } else if (state is CampaignLoading) {
      return state.campaigns.length;
    } else if (state is CampaignError) {
      return state.campaigns.length;
    }
    return 0;
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => CampaignFormDialog(
        onSubmit: (campaign, imageFile) async {
          if (imageFile != null) {
            try {
              final tempId = DateTime.now().millisecondsSinceEpoch.toString();
              final uploadCampaignImage = sl<UploadCampaignImage>();
              final imageUrl = await uploadCampaignImage(tempId, imageFile);

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
            }
          }

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

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
