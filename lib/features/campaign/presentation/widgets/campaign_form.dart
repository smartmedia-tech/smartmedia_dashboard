import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/entities/campaign.dart';
import 'package:smartmedia_campaign_manager/features/campaign/domain/usecases/upload_image.dart';
import 'package:smartmedia_campaign_manager/injection_container.dart' as di;

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

class _CampaignFormDialogState extends State<CampaignFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  late TextEditingController _formCampaignLogoController;
  CampaignStatus _status =
      CampaignStatus.draft;
  bool _isLoading = false;
  bool _isUploading = false;
  File? _imageFile;
  String? _imageUrl;
  final ImagePicker _picker = ImagePicker();

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
    _formCampaignLogoController = TextEditingController(text: _imageUrl ?? '');
    _status =
        widget.campaign?.status ?? CampaignStatus.draft;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _formCampaignLogoController.dispose();
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

    setState(() => _isLoading = true);

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
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.campaign == null
                        ? 'Create Campaign'
                        : 'Edit Campaign',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 32),

              // Form content
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image picker section
                        Center(
                          child: Column(
                            children: [
                              _buildImageSelector(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),

                        // Basic info section
                        Text(
                          'Campaign Details',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Campaign Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.campaign),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descController,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 24),

                        // Date and status section
                        Text(
                          'Schedule & Status',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _DatePickerField(
                                label: 'Start Date',
                                value: _startDate,
                                onSelect: (date) =>
                                    setState(() => _startDate = date),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _DatePickerField(
                                label: 'End Date',
                                value: _endDate,
                                onSelect: (date) =>
                                    setState(() => _endDate = date),
                                minDate: _startDate,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<CampaignStatus>(
                          value: _status,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.stairs),
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
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _status = value!),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Action buttons
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(widget.campaign == null
                            ? 'Create Campaign'
                            : 'Update Campaign'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
            // For web platform
            _imageFile = File(pickedFile.path);
          } else {
            // For mobile platforms
            _imageFile = File(pickedFile.path);
          }
          _isUploading = true;
        });

        // Generate a temporary ID if we don't have a campaign ID yet
        final String tempId = widget.campaign?.id ??
            DateTime.now().millisecondsSinceEpoch.toString();

        try {
          // Use the injected UploadCampaignImage use case
          final uploadImageUseCase = di.sl<UploadCampaignImage>();
          final String downloadUrl =
              await uploadImageUseCase(tempId, _imageFile!);

          setState(() {
            _imageUrl = downloadUrl;
            _isUploading = false;
          });

          // Update your form state or controller to save this URL
          _formCampaignLogoController.text = downloadUrl;
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
          'Upload Campaign Image',
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

    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: minDate ??
              DateTime.now().subtract(const Duration(
                  days: 30)), // Allow picking dates from a month ago
          lastDate: DateTime(2100),
        );
        if (date != null) onSelect(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(formatter.format(value)),
      ),
    );
  }
}
