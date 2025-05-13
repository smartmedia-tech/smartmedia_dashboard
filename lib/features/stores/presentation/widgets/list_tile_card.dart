import 'package:flutter/material.dart';

class StoreListTile extends StatefulWidget {
  final dynamic store;
  final VoidCallback onTap;

  const StoreListTile({
    required this.store,
    required this.onTap,
    super.key,
  });

  @override
  State<StoreListTile> createState() => _StoreListTileState();
}

class _StoreListTileState extends State<StoreListTile> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isHovering
              ? Theme.of(context).hoverColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          onTap: widget.onTap,
          leading: Hero(
            tag: 'store_image_${widget.store.id}',
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: widget.store.imageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(widget.store.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[200],
              ),
              child: widget.store.imageUrl == null
                  ? Icon(
                      Icons.store,
                      size: 30,
                      color: Colors.grey[400],
                    )
                  : null,
            ),
          ),
          title: Hero(
            tag: 'store_name_${widget.store.id}',
            child: Text(
              widget.store.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          subtitle: Text(
            widget.store.address ?? 'No address provided',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.point_of_sale,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.store.tills.length} tills',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Colors.green[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.store.tills.where((t) => t.isOccupied).length} active',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green[700],
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
