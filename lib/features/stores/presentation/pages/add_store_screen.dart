import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_event.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_state.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/add%20store/form_fields.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/add%20store/store_image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddStoreScreen extends StatefulWidget {
  const AddStoreScreen({super.key});

  @override
  State<AddStoreScreen> createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _siteNumberController = TextEditingController();
  final _tillCountController = TextEditingController(text: '1');

  String _selectedRegion = '';
  File? _imageFile;
  bool _isLoading = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _siteNumberController.dispose();
    _tillCountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onImageSelected(File imageFile) {
    setState(() => _imageFile = imageFile);
  }

  void _onRegionSelected(String region) {
    setState(() => _selectedRegion = region);
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      context.read<StoresBloc>().add(
            AddStore(
              name: _nameController.text,
              region: _selectedRegion,
              siteNumber: _siteNumberController.text,
              tillCount: int.parse(_tillCountController.text),
              imageFile: _imageFile,
            ),
          );

      _animationController.forward();

      // Close after delay if still mounted
      Future.delayed(800.milliseconds).then((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Store'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<StoresBloc, StoresState>(
        listener: (context, state) {
          if (state is StoresError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                StoreImagePicker(
                  imageFile: _imageFile,
                  onImageSelected: _onImageSelected,
                ),
                const SizedBox(height: 10),
                StoreFormFields(
                  nameController: _nameController,
                  siteNumberController: _siteNumberController,
                  tillCountController: _tillCountController,
                  selectedRegion: _selectedRegion,
                  onRegionSelected: _onRegionSelected,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, _) {
                      return ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Add Store'),
                      );
                    },
                  ),
                ).animate().fadeIn(delay: 300.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
