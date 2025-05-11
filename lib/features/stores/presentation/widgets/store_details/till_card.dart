import 'package:flutter/material.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';

class TillCard extends StatelessWidget {
  final Till till;

  const TillCard({required this.till, super.key});

  @override
  Widget build(BuildContext context) {
    final isOccupied = till.isOccupied;
    final color = isOccupied ? Colors.red.shade100 : Colors.green.shade100;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOccupied ? Icons.person : Icons.person_outline,
              color: isOccupied ? Colors.red : Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Till ${till.number}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isOccupied ? Colors.red.shade800 : Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isOccupied ? 'Occupied' : 'Available',
            style: TextStyle(
              fontSize: 10,
              color: isOccupied ? Colors.red.shade800 : Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
