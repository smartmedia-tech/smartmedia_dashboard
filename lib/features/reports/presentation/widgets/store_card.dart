import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:smartmedia_campaign_manager/features/reports/presentation/widgets/till_image_gallery.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';

class StoreCard extends StatelessWidget {
  final Store store;

  const StoreCard({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate occupied tills for the campaign relevant to this store card preview
    // Assuming 'currentCampaignId' on Till helps determine if it's occupied by the selected campaign
    final int campaignOccupiedTills = store.tills
        .where((till) =>
            till.currentCampaignId ==
            (context.read<ReportsBloc>().state is ReportsLoaded
                ? (context.read<ReportsBloc>().state as ReportsLoaded)
                    .selectedCampaign
                    ?.id
                : null))
        .length;

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
              // Use the calculated campaignOccupiedTills here
              '$campaignOccupiedTills/${store.totalTills} tills occupied for selected campaign',
              style: TextStyle(
                color: campaignOccupiedTills > 0 ? Colors.green : Colors.orange,
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
                if (store.imageUrl != null && store.imageUrl!.isNotEmpty) ...[
                  // Null and empty string check
                  const Text(
                    'Store Image:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      store
                          .imageUrl!, // Use non-null asserted as it's checked above
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
                      // Determine if this specific till is occupied by the selected campaign
                      final bool isTillOccupiedBySelectedCampaign = till
                              .currentCampaignId ==
                          (context.read<ReportsBloc>().state is ReportsLoaded
                              ? (context.read<ReportsBloc>().state
                                      as ReportsLoaded)
                                  .selectedCampaign
                                  ?.id
                              : null);

                      return GestureDetector(
                        onTap: () {
                          if (till.images?.isNotEmpty == true) {
                            // Correct null-safe check
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TillImageGallery(
                                  till: till,
                                  storeName: store.name,
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('No images available for this till.'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isTillOccupiedBySelectedCampaign
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            border: Border.all(
                              color: isTillOccupiedBySelectedCampaign
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isTillOccupiedBySelectedCampaign
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isTillOccupiedBySelectedCampaign
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
                              if (till.images?.isNotEmpty ==
                                  true) // Correct null-safe check
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
