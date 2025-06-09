import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/widgets/till_image_gallery.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';

class StoreCard extends StatelessWidget {
  final Store store;

  const StoreCard({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.store,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          store.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Region: ${store.region}'),
            Text('Site: ${store.siteNumber}'),
            Text(
              '${store.occupiedTills}/${store.totalTills} tills occupied',
              style: TextStyle(
                color: store.occupiedTills.length > 0 ? Colors.green : Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (store.imageUrl != null) ...[
                  const Text(
                    'Store Image:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      store.imageUrl ?? '',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                const Text(
                  'Tills:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                if (store.tills.isEmpty)
                  const Text(
                    'No tills available',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: store.tills.length,
                    itemBuilder: (context, index) {
                      final till = store.tills[index];
                      return GestureDetector(
                        onTap: () {
                          if (till.images != null ||
                              till.images.isNotEmpty) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TillImageGallery(
                                  till: till,
                                  storeName: store.name,
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: till.isOccupied
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            border: Border.all(
                              color: till.isOccupied
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                till.isOccupied
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: till.isOccupied
                                    ? Colors.green
                                    : Colors.orange,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Till ${till.number}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              if (till.images != null ||
                                  till.images.isNotEmpty)
                                Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
