import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/reports/domain/entities/report.dart'; // Import Report and ReportMetrics
import 'package:smartmedia_campaign_manager/features/reports/presentation/widgets/store_card.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';

class ReportPreview extends StatelessWidget {
  final Campaign campaign;
  final List<Store> stores;

  const ReportPreview({
    Key? key,
    required this.campaign,
    required this.stores,
  }) : super(key: key);

  // Helper to calculate metrics for the preview
  ReportMetrics _calculateMetrics(
      Campaign currentCampaign, List<Store> currentStores) {
    final totalStores = currentStores.length;
    final totalTills =
        currentStores.fold(0, (sum, store) => sum + store.totalTills);

    // Filter tills specific to the campaign in this report for accurate occupied count
    final List<Till> campaignSpecificTills = currentStores
        .expand((store) => store.tills)
        .where((till) => till.currentCampaignId == currentCampaign.id)
        .toList();

    final occupiedTills = campaignSpecificTills.length;
    final availableTills = totalTills - occupiedTills;

    // Assuming store.imageUrl is a single String URL:
    final storesWithImages = currentStores
        .where((store) => store.imageUrl != null && store.imageUrl!.isNotEmpty)
        .length;

    final tillsWithImages = campaignSpecificTills.fold(
      0,
      (sum, till) => sum + (till.images.isNotEmpty == true ? 1 : 0),
    );

    final occupancyRate =
        totalTills > 0 ? (occupiedTills / totalTills) * 100 : 0.0;

    return ReportMetrics(
      totalStores: totalStores,
      totalTills: totalTills,
      occupiedTills: occupiedTills,
      availableTills: availableTills,
      storesWithImages: storesWithImages,
      tillsWithImages: tillsWithImages,
      occupancyRate: occupancyRate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final metrics = _calculateMetrics(campaign, stores);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Preview: ${campaign.name}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Summary Statistics using calculated metrics
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Stores',
                    value: metrics.totalStores.toString(),
                    icon: Icons.store,
                  ),
                  _StatItem(
                    label: 'Total Tills',
                    value: metrics.totalTills.toString(),
                    icon: Icons.point_of_sale,
                  ),
                  _StatItem(
                    label: 'Occupied',
                    value: metrics.occupiedTills.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _StatItem(
                    label: 'Occupancy',
                    value: '${metrics.occupancyRate.toStringAsFixed(1)}%',
                    icon: Icons.analytics,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            const Text(
              'Stores in Campaign',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Stores List
            if (stores.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'No stores found for this campaign',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stores.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return StoreCard(
                    store: stores[index],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Theme.of(context).primaryColor,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
