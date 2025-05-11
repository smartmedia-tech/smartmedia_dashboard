import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_event.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_state.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/pages/till_images_screen.dart';

class TillOptionsBottomSheet extends StatelessWidget {
  final String storeId;
  final Till till;

  const TillOptionsBottomSheet({
    super.key,
    required this.storeId,
    required this.till,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<StoresBloc, StoresState>(
      listener: (context, state) {
        if (state is StoresError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is TillImagesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: till.isOccupied ? Colors.red.shade50 : Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            till.isOccupied ? Icons.person : Icons.person_outline,
            color: till.isOccupied ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Till ${till.number}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              till.isOccupied ? 'Occupied' : 'Available',
              style: TextStyle(
                color: till.isOccupied ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _buildActionButton(
          icon: till.isOccupied
              ? Icons.check_circle_outline
              : Icons.remove_circle_outline,
          label: till.isOccupied ? 'Mark Available' : 'Mark Occupied',
          color: till.isOccupied ? Colors.green : Colors.red,
          onPressed: () => _updateStatus(context),
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          icon: Icons.image_outlined,
          label: 'Add Image',
          color: Colors.blue,
          onPressed: () => _addImage(context),
        ),
        const SizedBox(height: 12),
        if (till.imageUrls.isNotEmpty)
          _buildActionButton(
            icon: Icons.photo_library_outlined,
            label: 'View Images',
            color: Colors.purple,
            onPressed: () => _viewImages(context),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(label),
        ],
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
    // Get the bloc reference first
    final bloc = context.read<StoresBloc>();

    // Then pop the bottom sheet
    Navigator.pop(context);

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Use the stored bloc reference
      bloc.add(
        UploadTillImage(
          storeId: storeId,
          tillId: till.id,
          imageFile: File(pickedFile.path),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TillOptionsBottomSheet(
        storeId: storeId,
        till: till,
      ),
    );
  }
}
