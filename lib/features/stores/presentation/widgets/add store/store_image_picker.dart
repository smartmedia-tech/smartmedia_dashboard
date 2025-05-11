import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartmedia_campaign_manager/core/utils/colors.dart';

class StoreImagePicker extends StatelessWidget {
  final File? imageFile;
  final Function(File) onImageSelected;

  const StoreImagePicker({
    super.key,
    required this.imageFile,
    required this.onImageSelected,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ).animate().fadeIn(duration: const Duration(milliseconds: 300)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageSourceOption(
                      context: context,
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () async {
                        Navigator.pop(context);
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.gallery);
                        _processPickedImage(pickedFile);
                      },
                      delay: 100,
                    ),
                    _buildImageSourceOption(
                      context: context,
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () async {
                        Navigator.pop(context);
                        final pickedFile =
                            await picker.pickImage(source: ImageSource.camera);
                        _processPickedImage(pickedFile);
                      },
                      delay: 200,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuad,
            );
      },
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required int delay,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.dividerColorDark : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideY(begin: 0.2, end: 0, delay: Duration(milliseconds: delay));
  }

  void _processPickedImage(XFile? pickedFile) {
    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: () => _pickImage(context),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? AppColors.dividerColorDark.withOpacity(.2)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
                image: imageFile != null
                    ? DecorationImage(
                        image: FileImage(imageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: imageFile == null
                  ? Center(
                      child: Icon(
                        Icons.store_outlined,
                        size: 50,
                        color: isDarkMode
                            ? AppColors.background.withOpacity(.5)
                            : Colors.grey.shade400,
                      )
                          .animate(
                              onPlay: (controller) =>
                                  controller.repeat(reverse: true))
                          .fadeIn(duration: const Duration(milliseconds: 1500))
                          .then()
                          .fadeOut(
                              duration: const Duration(milliseconds: 1500)),
                    )
                  : null,
            ),
          ).animate().scale(
              duration: const Duration(milliseconds: 400),
              begin: const Offset(0.8, 0.8),
              end: const Offset(1, 1)),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 18,
            ),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 200))
              .slideY(
                  begin: 0.5, end: 0, delay: const Duration(milliseconds: 200))
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(
                  begin: 1,
                  end: 1.1,
                  duration: const Duration(milliseconds: 1500)),
        ],
      ),
    );
  }
}
