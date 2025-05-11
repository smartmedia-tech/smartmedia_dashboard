import 'package:flutter/material.dart';

class TillImagesFab extends StatelessWidget {
  final bool isUploading;
  final bool isImageExpanded;
  final VoidCallback onPressed;

  const TillImagesFab({
    super.key,
    required this.isUploading,
    required this.isImageExpanded,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isUploading || isImageExpanded ? null : onPressed,
      backgroundColor: isUploading || isImageExpanded
          ? Colors.grey
          : Theme.of(context).primaryColor,
      child: isUploading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.add_a_photo),
    );
  }
}
