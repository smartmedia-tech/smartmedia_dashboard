// lib/features/reports/presentation/widgets/report_preview.dart
import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/reports/domain/entities/report.dart'; // Import Report and ReportMetrics
import 'package:smartmedia_campaign_manager/features/reports/presentation/widgets/store_card.dart'; // Assuming this is also styled
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

  ReportMetrics _calculateMetrics(
      Campaign currentCampaign, List<Store> currentStores) {
    final totalStores = currentStores.length;
    final totalTills =
        currentStores.fold(0, (sum, store) => sum + store.totalTills);

    final List<Till> campaignSpecificTills = currentStores
        .expand((store) => store.tills)
        .where((till) => till.currentCampaignId == currentCampaign.id)
        .toList();

    final occupiedTills = campaignSpecificTills.length;
    final availableTills = totalTills - occupiedTills;

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

    return Container(
      // Use a Container for a more prominent "card" feel
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
      ),
      child: Padding(
        padding: const EdgeInsets.all(24), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Preview: ${campaign.name}',
              style: TextStyle(
                // Use Theme context for consistency
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),

            // Summary Statistics using calculated metrics - Enhanced Design
            Container(
              padding: const EdgeInsets.all(16), // Increased padding
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Light blue accent
                borderRadius:
                    BorderRadius.circular(10), // Slightly more rounded
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Stores',
                    value: metrics.totalStores.toString(),
                    icon: Icons.store,
                    color: Theme.of(context)
                        .primaryColor, // Consistent primary color
                  ),
                  _StatItem(
                    label: 'Total Tills',
                    value: metrics.totalTills.toString(),
                    icon: Icons.point_of_sale,
                    color: Colors.green[600], // Deeper green
                  ),
                  _StatItem(
                    label: 'Occupied',
                    value: metrics.occupiedTills.toString(),
                    icon: Icons.check_circle,
                    color: Colors.deepOrange[600], // Deeper orange for occupied
                  ),
                  _StatItem(
                    label: 'Occupancy',
                    value: '${metrics.occupancyRate.toStringAsFixed(1)}%',
                    icon: Icons.analytics,
                    color: Colors.purple[600], // New color for analytics
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text(
              'Stores in Campaign',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            // Stores List
            if (stores.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Icon(Icons.store_mall_directory_outlined,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No stores associated with this campaign.',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stores.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12), // Slightly more space
                itemBuilder: (context, index) {
                  return StoreCard(
                    // Assuming StoreCard is also styled for dashboard
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
          size: 32, // Larger icons
        ),
        const SizedBox(height: 8), // More spacing
        Text(
          value,
          style: TextStyle(
            fontSize: 20, // Larger value text
            fontWeight: FontWeight.bold,
            color: color ?? Theme.of(context).primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14, // Slightly larger label
            color: Color(0xFF666666), // Consistent light grey text
          ),
        ),
      ],
    );
  }
}
