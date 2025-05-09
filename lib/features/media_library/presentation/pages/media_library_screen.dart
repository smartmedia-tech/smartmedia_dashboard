import 'package:flutter/material.dart';

class MediaLibraryScreen extends StatelessWidget {
  const MediaLibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Media Library Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
