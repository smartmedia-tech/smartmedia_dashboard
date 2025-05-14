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
           
            body: Column(
              children: [
                _StoreHeader(store: store),

                // Main content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _StoreContent(store: store, storeId: storeId),
                  ),
                ),
              ],
            ),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

class _StoreHeader extends StatelessWidget {
  final Store store;

  const _StoreHeader({required this.store});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
       
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Store image
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: store.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: store.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(Icons.store, size: 32),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(Icons.store, size: 32),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(Icons.store, size: 32),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 24),

          // Store info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      store.name,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        store.region,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.numbers,
                      text: 'Site #${store.siteNumber}',
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.calendar_today,
                      text: 'Created ${_formatDate(store.createdAt)}',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit Store'),
                onPressed: () => EditStoreDialog.show(context, store),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  side: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
         
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Just now';
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(color: Colors.grey[800]),
          ),
        ],
      ),
    );
  }
}

class _StoreContent extends StatelessWidget {
  final Store store;
  final String storeId;

  const _StoreContent({required this.store, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left sidebar with metrics
        SizedBox(
          width: 300,
          child: Column(
            children: [
              // Store metrics
              _StoreMetricsSection(store: store),
              const SizedBox(height: 24),

              // Additional info
              _AdditionalInfoSection(store: store),
            ],
          ),
        ),
        const SizedBox(width: 24),

        // Main content area
        Expanded(
          child: TillsManagementPanel(store: store, storeId: storeId),
        ),
      ],
    );
  }
}

class _StoreMetricsSection extends StatelessWidget {
  final Store store;

  const _StoreMetricsSection({required this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STORE METRICS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _MetricTile(
              icon: Icons.point_of_sale,
              title: 'Total Tills',
              value: store.totalTills.toString(),
              color: Colors.deepPurple,
            ),
            const Divider(height: 24),
            _MetricTile(
              icon: Icons.bolt,
              title: 'Active Tills',
              value: store.occupiedTills.toString(),
              color: Colors.green,
            ),
            const Divider(height: 24),
            _MetricTile(
              icon: Icons.check_circle,
              title: 'Available Tills',
              value: store.availableTills.toString(),
              color: Colors.blue,
            ),
            const Divider(height: 24),
            _MetricTile(
              icon: Icons.access_time,
              title: 'Last Activity',
              value: '2h ago', // TODO: Replace with actual data
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdditionalInfoSection extends StatelessWidget {
  final Store store;

  const _AdditionalInfoSection({required this.store});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'STORE INFORMATION',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _InfoRow(icon: Icons.location_on, text: store.region),
            const SizedBox(height: 12),
            _InfoRow(icon: Icons.numbers, text: 'Site #${store.siteNumber}'),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.calendar_today,
              text: 'Created ${_formatDate(store.createdAt)}',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
