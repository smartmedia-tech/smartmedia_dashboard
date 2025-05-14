import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/stores_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_event.dart';

class EditStoreDialog extends StatelessWidget {
  final Store store;

  const EditStoreDialog({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: store.name);
    final regionController = TextEditingController(text: store.region);
    final siteNumberController = TextEditingController(text: store.siteNumber);
    final imageUrlController =
        TextEditingController(text: store.imageUrl ?? '');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: 500, // Fixed width for desktop dialog
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Edit Store Details',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  color: Colors.grey[700],
                ),
              ],
            ),
            const Divider(height: 32),

            // Form fields
            _buildTextField(
              context: context,
              controller: nameController,
              label: 'Store Name',
              icon: Icons.store,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context: context,
              controller: regionController,
              label: 'Region',
              icon: Icons.map,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context: context,
              controller: siteNumberController,
              label: 'Site Number',
              icon: Icons.pin,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              context: context,
              controller: imageUrlController,
              label: 'Image URL (optional)',
              icon: Icons.image,
            ),
            const SizedBox(height: 32),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    final updatedStore = store.copyWith(
                      name: nameController.text,
                      region: regionController.text,
                      siteNumber: siteNumberController.text,
                      imageUrl: imageUrlController.text.isNotEmpty
                          ? imageUrlController.text
                          : store.imageUrl,
                    );
                    context
                        .read<StoresBloc>()
                        .add(UpdateStore(store: updatedStore));
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }

  static void show(BuildContext context, Store store) {
    showDialog(
      context: context,
      builder: (context) => EditStoreDialog(store: store),
    );
  }
}
