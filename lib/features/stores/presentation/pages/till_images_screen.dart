import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartmedia_campaign_manager/features/stores/domain/entities/till_model.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_event.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_state.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/till_images/till_image_delete_dialog.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/till_images/till_image_source_sheet.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/till_images/till_images_list.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/till_images/till_images_loading.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/till_images/till_images_error.dart'
    as widgets;
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/till_images/till_image_overlay.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/till_images/till_images_fab.dart';

class TillImagesPage extends StatefulWidget {
  final String storeId;
  final Till till;

  const TillImagesPage({
    super.key,
    required this.storeId,
    required this.till,
  });

  @override
  State<TillImagesPage> createState() => _TillImagesPageState();
}

class _TillImagesPageState extends State<TillImagesPage> {
  final _scrollController = ScrollController();
  String? _expandedImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Implement pagination if needed
    }
  }

  void _fetchImages() {
    context.read<StoresBloc>().add(
          FetchTillImages(
            storeId: widget.storeId,
            tillId: widget.till.id,
          ),
        );
  }

  void _expandImage(String imageUrl) {
    setState(() {
      _expandedImageUrl = _expandedImageUrl == imageUrl ? null : imageUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Till ${widget.till.number} Images'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchImages,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background design element
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Main content
          BlocConsumer<StoresBloc, StoresState>(
            listener: (context, state) {
              if (state is TillImagesError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
              if (state is TillImageUploaded) {
                _fetchImages();
              }
            },
            builder: (context, state) {
              if (state is LoadingTillImages) {
                return const TillImagesLoading();
              } else if (state is TillImagesLoaded) {
                return TillImagesList(
                  images: state.images,
                  scrollController: _scrollController,
                  till: widget.till,
                  onImageTap: _expandImage,
                  onDeleteImage: _showDeleteDialog,
                );
              } else if (state is TillImagesError) {
                return widgets.TillImagesError(
                  message: state.message,
                  onRetry: _fetchImages,
                );
              }
              return const TillImagesLoading();
            },
          ),
          // Expanded image overlay
          if (_expandedImageUrl != null)
            TillImageOverlay(
              imageUrl: _expandedImageUrl!,
              onClose: () => setState(() => _expandedImageUrl = null),
            ),
        ],
      ),
      floatingActionButton: TillImagesFab(
        isUploading: context.select<StoresBloc, bool>(
          (bloc) => bloc.state is ImageUploading,
        ),
        isImageExpanded: _expandedImageUrl != null,
        onPressed: _showImageSourceDialog,
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => const TillImageSourceSheet(),
    );

    if (source != null) {
      _uploadImage(source);
    }
  }

  Future<void> _uploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile != null && mounted) {
      final File imageFile = File(pickedFile.path);
      context.read<StoresBloc>().add(
            UploadTillImage(
              storeId: widget.storeId,
              tillId: widget.till.id,
              imageFile: imageFile,
            ),
          );
    }
  }

  Future<void> _showDeleteDialog(String imageUrl) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => TillImageDeleteDialog(imageUrl: imageUrl),
    );

    if (shouldDelete == true && mounted) {
      // Implement delete functionality
    }
  }
}
