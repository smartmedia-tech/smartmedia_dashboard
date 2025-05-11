import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_state.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/store_details/edit_store_bottom_sheet.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/store_details/tills_grid.dart';

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
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    background: store.imageUrl != null
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
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  store.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                // if (store.address != null) ...[
                                //   const SizedBox(height: 8),
                                //   Row(
                                //     children: [
                                //       Icon(Icons.location_on_outlined,
                                //           size: 16, color: Colors.grey),
                                //       const SizedBox(width: 8),
                                //       Text(store.address!,
                                //           style: Theme.of(context)
                                //               .textTheme
                                //               .bodyMedium),
                                //     ],
                                //   ),
                                // ],
                                ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.map_outlined,
                                          size: 16, color: Colors.grey),
                                      const SizedBox(width: 8),
                                      Text(store.region,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit_outlined,
                                  color: Theme.of(context).primaryColor),
                            ),
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) =>
                                  EditStoreBottomSheet(store: store),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Stats Cards
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildDetailCard(
                            context,
                            'Total Tills',
                            '${store.tills.length}',
                            Icons.point_of_sale_outlined,
                          ),
                          _buildDetailCard(
                            context,
                            'Active Tills',
                            '${store.tills.where((t) => t.isOccupied).length}',
                            Icons.bolt_outlined,
                            color: Colors.green,
                          ),
                          _buildDetailCard(
                            context,
                            'Last Activity',
                            '2h ago', // You would calculate this
                            Icons.access_time_outlined,
                            color: Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Tills Section
                      Text('Tills Management',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  )),
                      const SizedBox(height: 16),
                      TillsGrid(store: store, storeId: storeId),
                    ]),
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

  Widget _buildDetailCard(
      BuildContext context, String title, String value, IconData icon,
      {Color color = Colors.deepPurple}) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
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
              const Icon(Icons.more_vert, size: 18, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 16),
          Text(title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  )),
          const SizedBox(height: 4),
          Text(value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )),
        ],
      ),
    );
  }
}
