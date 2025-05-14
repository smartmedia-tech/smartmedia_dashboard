import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';

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
    // Separate tills into occupied and available
    final occupiedTills = store.tills.where((till) => till.isOccupied).toList();
    final availableTills =
        store.tills.where((till) => !till.isOccupied).toList();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search/filter option
          Row(
            children: [
              Text(
                'Tills Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              // Search field
              SizedBox(
                width: 250,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search tills...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tabs for All/Occupied/Available
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TabBar(
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.grid_view_outlined, size: 18),
                            const SizedBox(width: 8),
                            Text('All (${store.tills.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded,
                                size: 18, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Text('Occupied (${occupiedTills.length})'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline,
                                size: 18, color: Colors.green.shade700),
                            const SizedBox(width: 8),
                            Text('Available (${availableTills.length})'),
                          ],
                        ),
                      ),
                    ],
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey.shade700,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorColor: Theme.of(context).primaryColor,
                    indicatorWeight: 3,
                  ),
                ),
                const SizedBox(height: 24),

                // Tab content
                SizedBox(
                  height: 500, // Fixed height for tab content
                  child: TabBarView(
                    children: [
                      // All Tills
                      _buildTillsGrid(context, store.tills),

                      // Occupied Tills
                      _buildTillsGrid(context, occupiedTills),

                      // Available Tills
                      _buildTillsGrid(context, availableTills),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTillsGrid(BuildContext context, List<Till> tills) {
    if (tills.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No tills found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: tills.length,
      itemBuilder: (context, index) {
        return _buildTillCard(context, tills[index]);
      },
    );
  }

  Widget _buildTillCard(BuildContext context, Till till) {
    final isOccupied = till.isOccupied;
    final color = isOccupied ? Colors.red : Colors.green;
    final bgColor = isOccupied ? Colors.red.shade50 : Colors.green.shade50;
    final borderColor =
        isOccupied ? Colors.red.shade200 : Colors.green.shade200;

    List<String> images = [];
    if (till.imageUrls.isNotEmpty) {
      images = till.imageUrls;
    } else if (till.imageUrl != null && till.imageUrl!.isNotEmpty) {
      images.add(till.imageUrl!);
    }

    return InkWell(
      // onTap: () => TillOptionsDialog.show(context, storeId, till),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image section or color banner
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image or placeholder
                    images.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: images[0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: bgColor,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: color,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: bgColor,
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: color.shade300,
                                  size: 32,
                                ),
                              ),
                            ),
                          )
                        : Container(
                            color: bgColor,
                            child: Center(
                              child: Icon(
                                isOccupied
                                    ? Icons.person
                                    : Icons.person_outline,
                                color: color,
                                size: 32,
                              ),
                            ),
                          ),

                    // Status badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOccupied ? Colors.red : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isOccupied ? 'OCCUPIED' : 'AVAILABLE',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info section
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Till ${till.number}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isOccupied ? 'Occupied' : 'Available',
                        style: TextStyle(
                          fontSize: 12,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
