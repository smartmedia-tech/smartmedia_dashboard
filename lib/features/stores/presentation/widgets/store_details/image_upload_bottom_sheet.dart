import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_event.dart';

class ImageUploadBottomSheet extends StatefulWidget {
  final String storeId;
  final String? tillId;

  const ImageUploadBottomSheet({
    required this.storeId,
    this.tillId,
    super.key,
  });

  @override
  State<ImageUploadBottomSheet> createState() => _ImageUploadBottomSheetState();
}

class _ImageUploadBottomSheetState extends State<ImageUploadBottomSheet> {
  bool _isUploading = false;
  late final StoresBloc _storesBloc;

  @override
  void initState() {
    super.initState();
    // Get the bloc reference during initState
    _storesBloc = BlocProvider.of<StoresBloc>(context);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      // Save the navigator context before async operations
      final navigatorContext = Navigator.of(context);

      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _isUploading = true;
        });

        final imageFile = File(pickedFile.path);

        // Use the stored bloc reference instead of context.read
        if (widget.tillId != null) {
          _storesBloc.add(UploadTillImage(
            storeId: widget.storeId,
            tillId: widget.tillId!,
            imageFile: imageFile,
          ));
        } else {
          _storesBloc.add(UploadStoreImage(
            storeId: widget.storeId,
            imageFile: imageFile,
          ));
        }

        // Check if the widget is still mounted before closing
        if (mounted) {
          // Pop the modal only if it's safe to do so
          navigatorContext.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const Text(
            'Upload Image',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (_isUploading)
            const CircularProgressIndicator()
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                _buildOptionButton(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
