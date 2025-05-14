import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartmedia_campaign_manager/config/theme/colors.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_bloc.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_event.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/bloc/stores_state.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/add%20store/form_fields.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/add%20store/province_dropdown.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/add%20store/store_image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddStoreDialog extends StatefulWidget {
  const AddStoreDialog({super.key});

  @override
  State<AddStoreDialog> createState() => _AddStoreDialogState();
}

class _AddStoreDialogState extends State<AddStoreDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _siteNumberController = TextEditingController();
  final _tillCountController = TextEditingController(text: '1');

  String _selectedRegion = '';
  File? _imageFile;
  bool _isLoading = false;
  bool _isSubmitted = false;
  late AnimationController _animationController;
  int _currentStep = 0;
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    for (var node in _focusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _siteNumberController.dispose();
    _tillCountController.dispose();
    _animationController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
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
      setState(() {
        _isLoading = true;
        _isSubmitted = true;
      });

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

      Future.delayed(1200.milliseconds).then((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool get _canProceed {
    if (_currentStep == 0) {
      return _nameController.text.isNotEmpty && _selectedRegion.isNotEmpty;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textTheme = theme.textTheme;

    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor:isDarkMode?AppColors.dividerColorDark: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: BlocListener<StoresBloc, StoresState>(
            listener: (context, state) {
              if (state is StoresError) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 900,
              height: 600,
              decoration: BoxDecoration(
                color:isDarkMode?AppColors.dividerColorDark: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: _isSubmitted && _isLoading
                  ? _buildSuccessView(primaryColor, textTheme)
                  : Row(
                      children: [
                        // Left sidebar with steps
                        Container(
                          width: 280,
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.05),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Add New Store',
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildStepIndicator(
                                0,
                                'Store Details',
                                'Basic information',
                                Icons.store,
                                primaryColor,
                              ),
                              _buildStepIndicator(
                                1,
                                'Configuration',
                                'Settings & Image',
                                Icons.settings,
                                primaryColor,
                              ),
                              const Spacer(),
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  'Campaign Manager',
                                  style: textTheme.titleMedium?.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Right side content
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header with close button
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                // Content area
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, animation) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: SlideTransition(
                                          position: Tween<Offset>(
                                            begin: const Offset(0.05, 0),
                                            end: Offset.zero,
                                          ).animate(animation),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: _currentStep == 0
                                        ? _buildStepOne(primaryColor, textTheme)
                                        : _buildStepTwo(
                                            primaryColor, textTheme),
                                  ),
                                ),
                                // Bottom actions
                                Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (_currentStep > 0)
                                        TextButton.icon(
                                          onPressed: _previousStep,
                                          icon: const Icon(Icons.arrow_back),
                                          label: const Text('Back'),
                                        )
                                      else
                                        const SizedBox.shrink(),
                                      ElevatedButton(
                                        onPressed:
                                            _canProceed ? _nextStep : null,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 32,
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _currentStep < 1
                                                  ? 'Continue'
                                                  : 'Add Store',
                                              style:
                                                  const TextStyle(fontSize: 16),
                                            ),
                                            if (!_isLoading) ...[
                                              const SizedBox(width: 8),
                                              const Icon(Icons.arrow_forward,
                                                  size: 18),
                                            ] else
                                              const SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ).animate().fadeIn(delay: 300.ms),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepOne(Color primaryColor, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: StoreFormFields(
        nameController: _nameController,
        siteNumberController: _siteNumberController,
        tillCountController: _tillCountController,
        selectedRegion: _selectedRegion,
        onRegionSelected: _onRegionSelected,
      ),
    );
  }

  Widget _buildStepTwo(Color primaryColor, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Store Configuration',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure store settings and upload an image',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          // Image picker
          Center(
            child: StoreImagePicker(
              imageFile: _imageFile,
              onImageSelected: _onImageSelected,
            ),
          ),
          const SizedBox(height: 32),
          // Till count field
          _buildTextField(
            label: 'Till Count',
            hint: 'Number of tills',
            prefixIcon: Icons.point_of_sale,
            controller: _tillCountController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the number of tills';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              if (int.parse(value) < 1) {
                return 'Till count must be at least 1';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String title, String subtitle,
      IconData icon, Color primaryColor) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color:
                  isActive || isCompleted ? primaryColor : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white)
                  : Icon(
                      icon,
                      color: isActive ? Colors.white : Colors.grey.shade600,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isActive || isCompleted
                        ? primaryColor
                        : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(prefixIcon),
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
              borderSide:
                  BorderSide(color: Theme.of(context).primaryColor, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(Color primaryColor, TextTheme textTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 100,
            color: primaryColor,
          ).animate().scale(
                duration: 600.ms,
                curve: Curves.elasticOut,
                begin: const Offset(0.2, 0.2),
                end: const Offset(1, 1),
              ),
          const SizedBox(height: 24),
          Text(
            'Store Added Successfully!',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            '${_nameController.text} has been added to your stores',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade700,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }
}

// Helper function to show the dialog
void showAddStoreDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const AddStoreDialog(),
  );
}
