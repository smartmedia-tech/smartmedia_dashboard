import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/core/utils/colors.dart';
import 'package:smartmedia_campaign_manager/features/campaign/presentation/widgets/error_display.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/repositories/store_repository.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_event.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_state.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/store_card.dart';
import 'store_details_screen.dart';
import 'add_store_dialog.dart';

class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedRegion;
  List<String> _availableRegions = [];
  bool _gridView = true;
  bool _isSearchExpanded = false;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<StoresBloc>().add(LoadStores());
    _loadRegions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    try {
      final storeRepository = context.read<StoreRepository>();
      final regions = await storeRepository.getUniqueRegions();
      setState(() {
        _availableRegions = regions;
      });
    } catch (e) {
      // Handle error
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Filter Stores'),
              if (_selectedRegion != null)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedRegion = null;
                    });
                    context
                        .read<StoresBloc>()
                        .add(const FilterStoresByRegion(null));
                    Navigator.pop(context);
                  },
                  child: const Text('Clear Filters'),
                ),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Region',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All Regions'),
                      selected: _selectedRegion == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedRegion = null;
                          });
                          context
                              .read<StoresBloc>()
                              .add(const FilterStoresByRegion(null));
                          Navigator.pop(context);
                        }
                      },
                    ),
                    ..._availableRegions.map((region) {
                      return ChoiceChip(
                        label: Text(region),
                        selected: _selectedRegion == region,
                        onSelected: (selected) {
                          setState(() {
                            _selectedRegion = selected ? region : null;
                          });
                          context.read<StoresBloc>().add(
                              FilterStoresByRegion(selected ? region : null));
                          Navigator.pop(context);
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
      BuildContext context, String title, String value, IconData icon,
      {Color color = Colors.deepPurple, bool isActive = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
                if (isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Active',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.green,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
// Minimalistic Header Section with Expandable Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Title
                Expanded(
                  child: Text(
                    'Store Management',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Expandable Search Field
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isSearchExpanded ? 240 : 40,
                  child: _isSearchExpanded
                      ? Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.grey[900]
                                : AppColors.dividerColorDark.withOpacity(.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDarkMode
                                  ? Colors.grey[800]!
                                  : AppColors.productsCard.withOpacity(.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Search Icon
                              IconButton(
                                icon: const Icon(Icons.search,
                                    color: Colors.grey, size: 40),
                                onPressed: () {
                                  // Already expanded, focus on text field
                                  _searchFocusNode.requestFocus();
                                },
                              ),
                              // Search TextField
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  decoration: const InputDecoration(
                                    hintText: 'Search stores...',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.only(right: 16),
                                  ),
                                  onChanged: (value) {
                                    context
                                        .read<StoresBloc>()
                                        .add(SearchStores(value));
                                  },
                                ),
                              ),
                              // Close Button when expanded
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.grey, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _isSearchExpanded = false;
                                    _searchController.clear();
                                    context
                                        .read<StoresBloc>()
                                        .add(const SearchStores(''));
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                            ],
                          ),
                        )
                      : IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.search, color: Colors.grey),
                          ),
                          onPressed: () {
                            setState(() {
                              _isSearchExpanded = true;
                              // Add a small delay to focus after animation starts
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                _searchFocusNode.requestFocus();
                              });
                            });
                          },
                        ),
                ),

                const SizedBox(width: 12),

                // Region Filter
                FilterChip(
                  label: Text(_selectedRegion ?? 'All Regions'),
                  avatar: _selectedRegion != null
                      ? const Icon(Icons.close, size: 16)
                      : const Icon(Icons.tune, size: 16),
                  onSelected: (_) => _showFilterDialog(context),
                  backgroundColor: _selectedRegion != null
                      ? theme.primaryColor.withOpacity(0.2)
                      : null,
                  visualDensity: VisualDensity.compact,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                ),

                const SizedBox(width: 12),

                // View Toggle
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                     
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _gridView ? Icons.view_list : Icons.grid_view,
                      color: theme.primaryColor,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _gridView = !_gridView;
                    });
                  },
                ),

                const SizedBox(width: 8),

                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: theme.primaryColor),
                  ),
                  tooltip: 'Add New Store',
                  onPressed: () => showAddStoreDialog(context),
                ),
              ],
            ),
          ),
          // Stats Overview
          BlocBuilder<StoresBloc, StoresState>(
            builder: (context, state) {
              if (state is StoresLoaded) {
                final totalStores = state.stores.length;
                final activeStores = state.stores
                    .where((s) => s.tills.any((t) => t.isOccupied))
                    .length;
                final totalTills = state.stores
                    .fold(0, (sum, store) => sum + store.tills.length);
                final activeTills = state.stores.fold(
                    0,
                    (sum, store) =>
                        sum + store.tills.where((t) => t.isOccupied).length);

                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                  child: Row(
                    children: [
                      _buildStatCard(
                        context,
                        'Total Stores',
                        totalStores.toString(),
                        Icons.storefront_rounded,
                      ),
                      _buildStatCard(
                        context,
                        'Active Stores',
                        '$activeStores/$totalStores',
                        Icons.store_rounded,
                        color: Colors.green,
                        isActive: true,
                      ),
                      _buildStatCard(
                        context,
                        'Total Tills',
                        totalTills.toString(),
                        Icons.point_of_sale,
                        color: Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        'Active Tills',
                        '$activeTills/$totalTills',
                        Icons.point_of_sale_rounded,
                        color: Colors.orange,
                        isActive: true,
                      ),
                    ],
                  ),
                );
              }
              return Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
                child: Row(
                  children: List.generate(
                      4,
                      (index) => _buildStatCard(
                            context,
                            'Loading...',
                            '--',
                            Icons.store,
                          )),
                ),
              );
            },
          ),

          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: BlocConsumer<StoresBloc, StoresState>(
                listener: (context, state) {
                  if (state is StoresError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is StoresLoading || state is StoresInitial) {
                    return _buildLoadingGrid();
                  }

                  if (state is StoresError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Unable to load stores'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<StoresBloc>().add(LoadStores());
                            },
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is StoresLoaded) {
                    final storesToDisplay = state.stores;

                    if (storesToDisplay.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.store_mall_directory_outlined,
                                size: 48, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text('No stores found',
                                style: theme.textTheme.titleMedium),
                            const SizedBox(height: 8),
                            Text('Add your first store to get started',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                )),
                            const SizedBox(height: 24),
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child:
                                    Icon(Icons.add, color: theme.primaryColor),
                              ),
                              tooltip: 'Add New Store',
                              onPressed: () => showAddStoreDialog(context),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                        onRefresh: () async {
                          context.read<StoresBloc>().add(const RefreshStores());
                          return Future.delayed(const Duration(seconds: 1));
                        },
                        child: _gridView
                            ? LayoutBuilder(
                                builder: (context, constraints) {
                                  final crossAxisCount =
                                      constraints.maxWidth ~/ 100;
                                  return GridView.builder(
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          crossAxisCount.clamp(1, 4),
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.8,
                                    ),
                                    itemCount: storesToDisplay.length,
                                    itemBuilder: (context, index) {
                                      final store = storesToDisplay[index];
                                      return StoreCard(
                                        store: store,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                StoreDetailsScreen(
                                                    storeId: store.id),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              )
                            : ListView.builder(
                                itemCount: storesToDisplay.length,
                                itemBuilder: (context, index) {
                                  final store = storesToDisplay[index];
                                  final activeTills = store.tills
                                      .where((t) => t.isOccupied)
                                      .length;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: store.imageUrl != null
                                              ? DecorationImage(
                                                  image: NetworkImage(
                                                      store.imageUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                          color: Colors.grey[100],
                                        ),
                                        child: store.imageUrl == null
                                            ? Icon(Icons.store,
                                                color: Colors.grey[400])
                                            : null,
                                      ),
                                      title: Text(
                                        store.name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        '$activeTills/${store.tills.length} tills active',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                      trailing: Icon(
                                        Icons.chevron_right,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StoreDetailsScreen(
                                                  storeId: store.id),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ));
                  }

                  return const ErrorDisplay(message: 'Something went wrong');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
