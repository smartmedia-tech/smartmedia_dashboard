import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/store_details/till_options_bottom_sheet.dart';

class TillsManagementPanel extends StatelessWidget {
  final Store store;
  final String storeId;

  const TillsManagementPanel({
    super.key,
    required this.store,
    required this.storeId,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with tabs
              _TillsHeader(store: store),
          
              const SizedBox(height: 24),

              // Tills grid
              Expanded(
                child: _TillsGrid(store: store, storeId: storeId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TillsHeader extends StatelessWidget {
  final Store store;

  const _TillsHeader({required this.store});

  @override
  Widget build(BuildContext context) {
    final occupiedCount = store.tills.where((t) => t.isOccupied).length;
    final availableCount = store.tills.length - occupiedCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tills Management',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            const SizedBox(width: 16),
          ],
        ),
        const SizedBox(height: 16),
        TabBar(
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[700],
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).primaryColor,
          ),
          tabs: [
            const Tab(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('All'),
              ),
            ),
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber, size: 16),
                    const SizedBox(width: 6),
                    Text('Occupied ($occupiedCount)'),
                  ],
                ),
              ),
            ),
            Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16),
                    const SizedBox(width: 6),
                    Text('Available ($availableCount)'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TillsGrid extends StatelessWidget {
  final Store store;
  final String storeId;

  const _TillsGrid({required this.store, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final tabController = DefaultTabController.of(context);

        return TabBarView(
          controller: tabController,
          children: [
            _buildTillsGrid(context, store.tills),
            _buildTillsGrid(
                context, store.tills.where((t) => t.isOccupied).toList()),
            _buildTillsGrid(
                context, store.tills.where((t) => !t.isOccupied).toList()),
          ],
        );
      },
    );
  }

  Widget _buildTillsGrid(BuildContext context, List<Till> tills) {
    if (tills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.point_of_sale_outlined,
                size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No tills found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: tills.length,
      itemBuilder: (context, index) {
        return _TillCard(till: tills[index], storeId: storeId);
      },
    );
  }
}

class _TillCard extends StatelessWidget {
  final Till till;
  final String storeId;

  const _TillCard({required this.till, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final isOccupied = till.isOccupied;
    final color = isOccupied ? Colors.red : Colors.green;
    final bgColor = isOccupied ? Colors.red.shade50 : Colors.green.shade50;
    final images = till.imageUrls.isNotEmpty
        ? till.imageUrls
        : till.imageUrl != null
            ? [till.imageUrl!]
            : [];

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => TillOptionsBottomSheet.show(context, storeId, till),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image or placeholder
                  images.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: CachedNetworkImage(
                            imageUrl: images[0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: bgColor,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: color,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: bgColor,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: color.withOpacity(0.5),
                                ),
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: bgColor,
                          child: Center(
                            child: Icon(
                              isOccupied ? Icons.person : Icons.person_outline,
                              color: color.withOpacity(0.5),
                              size: 36,
                            ),
                          ),
                        ),

                  // Status indicator
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isOccupied ? 'OCCUPIED' : 'AVAILABLE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Image count badge
                  if (images.length > 1)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '+${images.length - 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.point_of_sale,
                          size: 14,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Till ${till.number}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: isOccupied ? 1.0 : 0.0,
                    backgroundColor: Colors.grey[200],
                    color: color,
                    minHeight: 4,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}