import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_event.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_state.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/pages/till_images_screen.dart';

class TillOptionsDialog extends StatelessWidget {
  final String storeId;
  final Till till;

  const TillOptionsDialog({
    super.key,
    required this.storeId,
    required this.till,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoresBloc, StoresState>(
      listener: (context, state) {
        if (state is StoresError || state is TillImagesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text((state as dynamic).message)),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                const Divider(height: 30),
                _buildActionCards(context),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor:
              till.isOccupied ? Colors.red.shade100 : Colors.green.shade100,
          child: Icon(
            till.isOccupied ? Icons.person : Icons.person_outline,
            size: 32,
            color: till.isOccupied ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Till #${till.number}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              till.isOccupied ? 'Occupied' : 'Available',
              style: TextStyle(
                color: till.isOccupied ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCards(BuildContext context) {
    return Column(
      children: [
        _buildActionCard(
          icon: till.isOccupied
              ? Icons.check_circle_outline
              : Icons.remove_circle_outline,
          label: till.isOccupied ? 'Mark as Available' : 'Mark as Occupied',
          color: till.isOccupied ? Colors.green : Colors.red,
          onTap: () => _updateStatus(context),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.image_outlined,
          label: 'Add Till Image',
          color: Colors.blue,
          onTap: () => _addImage(context),
        ),
        if (till.images.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildActionCard(
            icon: Icons.photo_library_outlined,
            label: 'View Till Images',
            color: Colors.purple,
            onTap: () => _viewImages(context),
          ),
        ],
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: color.withOpacity(0.1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context) {
    Navigator.pop(context);
    context.read<StoresBloc>().add(
          UpdateTillStatus(
            storeId: storeId,
            tillId: till.id,
            isOccupied: !till.isOccupied,
          ),
        );
  }

  Future<void> _addImage(BuildContext context) async {
    Navigator.pop(context);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      context.read<StoresBloc>().add(
            UploadTillImage(
              storeId: storeId,
              tillId: till.id,
              imageFile: file,
            ),
          );
    }
  }

  void _viewImages(BuildContext context) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TillImagesPage(
          storeId: storeId,
          till: till,
        ),
      ),
    );
  }

  static void show(BuildContext context, String storeId, Till till) {
    showDialog(
      context: context,
      builder: (_) => TillOptionsDialog(storeId: storeId, till: till),
    );
  }
}
