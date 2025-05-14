import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_state.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/store_details/edit_store_bottom_sheet.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/store_details/store_metrics_card.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/store_details/tills_management_panel.dart';
class StoreDetailsScreen extends StatelessWidget {
  final String storeId;

  const StoreDetailsScreen({required this.storeId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StoresBloc, StoresState>(
      builder: (context, state) {
        if (state is StoresLoaded) {
          final store = state.stores.firstWhere((s) => s.id == storeId);
          return Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Check if we're on a desktop/large screen
                final isDesktop = constraints.maxWidth >= 1100;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Bar with store header
                    _buildStoreHeaderBar(context, store, isDesktop),

                    // Main content area
                    Expanded(
                      child: isDesktop
                          ? _buildDesktopLayout(context, store)
                          : _buildTabletLayout(context, store),
                    ),
                  ],
                );
              },
            ),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildStoreHeaderBar(
      BuildContext context, Store store, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
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
          // Store Image
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 200,
              height: 100,
              child: store.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: store.imageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.store, size: 48),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.store, size: 48),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 24),

          // Store Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),

                // Info row
                Wrap(
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    _buildInfoItem(
                        context, Icons.map_outlined, 'Region: ${store.region}'),
                    _buildInfoItem(context, Icons.pin_outlined,
                        'Site No: ${store.siteNumber}'),
                    _buildInfoItem(context, Icons.calendar_today_outlined,
                        'Created: ${_formatDate(store.createdAt)}'),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Store'),
            onPressed: () => EditStoreDialog.show(context, store),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, Store store) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel - Store metrics and information
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Store Metrics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Metrics cards
                StoreMetricsCard(
                  title: 'Total Tills',
                  value: '${store.totalTills}',
                  icon: Icons.point_of_sale_outlined,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                StoreMetricsCard(
                  title: 'Active Tills',
                  value: '${store.occupiedTills}',
                  icon: Icons.bolt_outlined,
                  color: Colors.green,
                ),
                const SizedBox(height: 16),
                StoreMetricsCard(
                  title: 'Available Tills',
                  value: '${store.availableTills}',
                  icon: Icons.check_circle_outline,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                StoreMetricsCard(
                  title: 'Last Activity',
                  value: '2h ago', // You would calculate this
                  icon: Icons.access_time_outlined,
                  color: Colors.orange,
                ),

                const SizedBox(height: 32),

                // Additional store information section
                Text(
                  'Store Information',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                // Additional info cards would go here
                // These could be created as separate components
              ],
            ),
          ),
        ),

        // Divider
        const VerticalDivider(width: 1),

        // Right panel - Tills management
        Expanded(
          flex: 2,
          child: TillsManagementPanel(store: store, storeId: storeId),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context, Store store) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics section
          Text(
            'Store Metrics',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Metrics grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 2.5,
            children: [
              StoreMetricsCard(
                title: 'Total Tills',
                value: '${store.totalTills}',
                icon: Icons.point_of_sale_outlined,
                color: Colors.deepPurple,
              ),
              StoreMetricsCard(
                title: 'Active Tills',
                value: '${store.occupiedTills}',
                icon: Icons.bolt_outlined,
                color: Colors.green,
              ),
              StoreMetricsCard(
                title: 'Available Tills',
                value: '${store.availableTills}',
                icon: Icons.check_circle_outline,
                color: Colors.blue,
              ),
              StoreMetricsCard(
                title: 'Last Activity',
                value: '2h ago', // You would calculate this
                icon: Icons.access_time_outlined,
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Tills management section
          Text(
            'Tills Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Tills panel
          TillsManagementPanel(store: store, storeId: storeId),
        ],
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[800],
              ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
