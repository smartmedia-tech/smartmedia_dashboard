import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';

class StoreInfoCard extends StatelessWidget {
  final Store store;

  const StoreInfoCard({required this.store, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TILLS OVERVIEW',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatsCard(
                  context: context,
                  icon: Icons.grid_view_rounded,
                  label: 'Total',
                  value: '${store.totalTills}',
                  backgroundColor: Colors.blue.shade50,
                  iconColor: Colors.blue.shade700,
                  textColor: Colors.blue.shade900,
                ),
                const SizedBox(width: 8),
                _buildStatsCard(
                  context: context,
                  icon: Icons.check_circle_rounded,
                  label: 'Available',
                  value: '${store.availableTills}',
                  backgroundColor: Colors.green.shade50,
                  iconColor: Colors.green.shade600,
                  textColor: Colors.green.shade900,
                  showPercentage: true,
                  total: store.totalTills,
                  count: store.availableTills,
                ),
                const SizedBox(width: 8),
                _buildStatsCard(
                  context: context,
                  icon: Icons.cancel_rounded,
                  label: 'Occupied',
                  value: '${store.occupiedTills}',
                  backgroundColor: Colors.red.shade50,
                  iconColor: Colors.red.shade600,
                  textColor: Colors.red.shade900,
                  showPercentage: true,
                  total: store.totalTills,
                  count: store.occupiedTills,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required Color backgroundColor,
    required Color iconColor,
    required Color textColor,
    bool showPercentage = false,
    int? total,
    int? count,
  }) {
    String percentageText = '';
    if (showPercentage && total != null && count != null && total > 0) {
      int percentage = ((count / total) * 100).round();
      percentageText = '$percentage%';
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                if (percentageText.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    percentageText,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
