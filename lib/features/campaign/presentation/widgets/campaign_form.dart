import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/usecases/upload_image.dart';
import 'package:smartmedia_campaign_manager/injection_container.dart' as di;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartmedia_campaign_manager/config/theme/colors.dart';

class CampaignFormDialog extends StatefulWidget {
  final Campaign? campaign;
  final Function(Campaign, File?) onSubmit;

  const CampaignFormDialog({
    super.key,
    this.campaign,
    required this.onSubmit,
  });

  @override
  State<CampaignFormDialog> createState() => _CampaignFormDialogState();
}

class _CampaignFormDialogState extends State<CampaignFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  CampaignStatus _status = CampaignStatus.draft;
  bool _isLoading = false;
  bool _isUploading = false;
  File? _imageFile;
  String? _imageUrl;
  bool _isSubmitted = false;
  late AnimationController _animationController;
  int _currentStep = 0;
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.campaign?.name ?? '');
    _descController =
        TextEditingController(text: widget.campaign?.description ?? '');
    _startDate = widget.campaign?.startDate ?? DateTime.now();
    _endDate = widget.campaign?.endDate ??
        DateTime.now().add(const Duration(days: 30));
    _imageUrl = widget.campaign?.clientLogoUrl;
    _status = widget.campaign?.status ?? CampaignStatus.draft;
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
    _descController.dispose();
    _animationController.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('End date must be after start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isSubmitted = true;
    });

    final campaign = Campaign(
      id: widget.campaign?.id ?? '',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
      clientLogoUrl: _imageUrl ?? widget.campaign?.clientLogoUrl,
    );

    widget.onSubmit(campaign, _imageFile);
    _animationController.forward();

    Future.delayed(1200.milliseconds).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          if (kIsWeb) {
            _imageFile = File(pickedFile.path);
          } else {
            _imageFile = File(pickedFile.path);
          }
          _isUploading = true;
        });

        final String tempId = widget.campaign?.id ??
            DateTime.now().millisecondsSinceEpoch.toString();

        try {
          final uploadImageUseCase = di.sl<UploadCampaignImage>();
          final String downloadUrl =
              await uploadImageUseCase(tempId, _imageFile!);

          setState(() {
            _imageUrl = downloadUrl;
            _isUploading = false;
          });
        } catch (e) {
          setState(() {
            _isUploading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error uploading image: ${e.toString()}')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString()}')),
      );
    }
  }

  void _nextStep() {
    if (_currentStep < 1) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool get _canProceed {
    if (_currentStep == 0) {
      return _nameController.text.isNotEmpty && _descController.text.isNotEmpty;
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
      backgroundColor: isDarkMode ? AppColors.dividerColorDark : Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 900,
            height: 600,
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.dividerColorDark : Colors.white,
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
                                widget.campaign == null
                                    ? 'Create Campaign'
                                    : 'Edit Campaign',
                                style: textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildStepIndicator(
                              0,
                              'Campaign Details',
                              'Basic information',
                              Icons.campaign,
                              primaryColor,
                            ),
                            _buildStepIndicator(
                              1,
                              'Schedule & Status',
                              'Dates and status',
                              Icons.calendar_today,
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
                                      : _buildStepTwo(primaryColor, textTheme),
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
                                      onPressed: _canProceed ? _nextStep : null,
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
                                                : widget.campaign == null
                                                    ? 'Create Campaign'
                                                    : 'Update Campaign',
                                            style: const TextStyle(fontSize: 16),
                                          ),
                                          if (!_isLoading) ...[
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward,
                                                size: 18),
                                          ] else
                                            const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
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
    );
  }

  Widget _buildStepOne(Color primaryColor, TextTheme textTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Campaign Details',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter basic information about your campaign',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          // Name field
          _buildTextField(
            label: 'Campaign Name',
            hint: 'Enter campaign name',
            prefixIcon: Icons.campaign,
            controller: _nameController,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          // Description field
          _buildTextField(
            label: 'Description',
            hint: 'Enter campaign description',
            prefixIcon: Icons.description,
            controller: _descController,
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          // Image picker
          Center(
            child: _buildImageSelector(),
          ),
        ],
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
            'Schedule & Status',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure campaign schedule and status',
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),
          // Date pickers
          Row(
            children: [
              Expanded(
                child: _DatePickerField(
                  label: 'Start Date',
                  value: _startDate,
                  onSelect: (date) => setState(() => _startDate = date),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DatePickerField(
                  label: 'End Date',
                  value: _endDate,
                  onSelect: (date) => setState(() => _endDate = date),
                  minDate: _startDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Status dropdown
          DropdownButtonFormField<CampaignStatus>(
            value: _status,
            decoration: InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.stairs),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            items: CampaignStatus.values.map((status) {
              return DropdownMenuItem<CampaignStatus>(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStatusLabel(status),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) => setState(() => _status = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelector() {
    return Container(
      width: 220,
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: _isUploading ? null : _pickImage,
        borderRadius: BorderRadius.circular(12),
        child: _isUploading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 8),
                    Text('Uploading...'),
                  ],
                ),
              )
            : _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: kIsWeb
                        ? Image.network(
                            _imageFile!.path,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                  )
                : _imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(),
                        ),
                      )
                    : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: Colors.grey.shade500,
        ),
        const SizedBox(height: 12),
        Text(
          'Upload Campaign Logo',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Click to browse',
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
        ),
      ],
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
    int maxLines = 1,
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
          maxLines: maxLines,
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
            widget.campaign == null
                ? 'Campaign Created!'
                : 'Campaign Updated!',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Text(
            '${_nameController.text} has been ${widget.campaign == null ? 'created' : 'updated'} successfully',
            style: textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade700,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Color _getStatusColor(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return Colors.grey.shade600;
      case CampaignStatus.active:
        return Colors.green;
      case CampaignStatus.paused:
        return Colors.orange;
      case CampaignStatus.completed:
        return Colors.blue;
      case CampaignStatus.archived:
        return Colors.purple;
    }
  }

  String _getStatusLabel(CampaignStatus status) {
    switch (status) {
      case CampaignStatus.draft:
        return 'Draft';
      case CampaignStatus.active:
        return 'Active';
      case CampaignStatus.paused:
        return 'Paused';
      case CampaignStatus.completed:
        return 'Completed';
      case CampaignStatus.archived:
        return 'Archived';
    }
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final Function(DateTime) onSelect;
  final DateTime? minDate;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onSelect,
    this.minDate,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM dd, yyyy');

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
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: minDate ?? DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime(2100),
            );
            if (date != null) onSelect(date);
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: const Icon(Icons.calendar_today),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            child: Text(formatter.format(value)),
          ),
        ),
      ],
    );
  }
}