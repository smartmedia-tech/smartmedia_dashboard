import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/campaign.dart';

class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onView;
  final double width;
  final double height;

  const CampaignCard({
    super.key,
    required this.campaign,
    this.onDelete,
    this.onEdit,
    this.onView,
    this.width = 340,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM dd, yyyy');
    final now = DateTime.now();
    final isActive =
        now.isAfter(campaign.startDate) && now.isBefore(campaign.endDate);
    final isUpcoming = now.isBefore(campaign.startDate);
    final isPast = now.isAfter(campaign.endDate);

    Color statusColor;
    String statusText;

    if (isActive) {
      statusColor = Colors.green.shade600;
      statusText = 'Active';
    } else if (isUpcoming) {
      statusColor = Colors.blue.shade600;
      statusText = 'Upcoming';
    } else {
      statusColor = Colors.grey.shade600;
      statusText = 'Completed';
    }

    return Container(
      width: width,
      height: height,
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campaign Image
            Container(
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    campaign.clientLogoUrl ??
                        'https://via.placeholder.com/600x400?text=${campaign.name}',
                  ),
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                ),
              ),
              child: Stack(
                children: [
                  // Status chip in top-left corner
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Menu in top-right corner
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.black87),
                        onSelected: (value) {
                          if (value == 'view' && onView != null) {
                            onView!();
                          } else if (value == 'edit' && onEdit != null) {
                            onEdit!();
                          } else if (value == 'delete' && onDelete != null) {
                            onDelete!();
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 18),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 18),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 18, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Campaign name
                    Text(
                      campaign.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    
                    // Description
                    Text(
                      campaign.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    Spacer(),
                    
                    // Date information
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${formatter.format(campaign.startDate)} - ${formatter.format(campaign.endDate)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 12),
                    
                    // Progress bar
                    if (isActive) _buildProgressIndicator(campaign.startDate, campaign.endDate),
                    
                    if (isUpcoming) 
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.blue[600]),
                          SizedBox(width: 8),
                          Text(
                            'Starts in ${campaign.startDate.difference(now).inDays} days',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      
                    if (isPast)
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: Colors.grey[600]),
                          SizedBox(width: 8),
                          Text(
                            'Ended ${now.difference(campaign.endDate).inDays} days ago',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            
            // Action buttons
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onView,
                      icon: Icon(Icons.visibility, size: 18),
                      label: Text('View'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(DateTime start, DateTime end) {
    final now = DateTime.now();
    final totalDuration = end.difference(start).inDays;
    final elapsedDuration = now.difference(start).inDays;

    // Calculate progress (0.0 to 1.0)
    final progress = elapsedDuration / totalDuration;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Campaign progress',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}