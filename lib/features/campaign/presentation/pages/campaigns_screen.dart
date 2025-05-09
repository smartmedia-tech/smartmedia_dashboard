import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/campaign_bloc.dart';
import '../bloc/campaign_event.dart';
import '../bloc/campaign_state.dart';
import '../../domain/entities/campaign.dart';
import '../widgets/campaign_card.dart';
import '../widgets/empty_campaigns_placeholder.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_display.dart';

class CampaignScreen extends StatefulWidget {
  const CampaignScreen({super.key});

  @override
  State<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends State<CampaignScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load campaigns when the screen initializes
    context.read<CampaignBloc>().add(LoadCampaigns());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _showCreateDialog() {
    _nameController.clear();
    _descController.clear();
    _startDate = null;
    _endDate = null;
    _isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Create Campaign',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Campaign Name',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.campaign),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Name required' : null,
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _descController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 3,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Description required'
                              : null,
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _DatePickerField(
                                label: 'Start Date',
                                value: _startDate,
                                onSelect: (date) {
                                  setDialogState(() => _startDate = date);
                                },
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _DatePickerField(
                                label: 'End Date',
                                value: _endDate,
                                onSelect: (date) {
                                  setDialogState(() => _endDate = date);
                                },
                                minDate: _startDate,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text('Create'),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState?.validate() != true ||
                              _startDate == null ||
                              _endDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill all fields'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (_endDate!.isBefore(_startDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('End date must be after start date'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => _isLoading = true);

                          final campaign = Campaign(
                            id: '',
                            name: _nameController.text.trim(),
                            description: _descController.text.trim(),
                            startDate: _startDate!,
                            endDate: _endDate!,
                          );

                          context.read<CampaignBloc>().add(AddCampaign(campaign));
                          
                          // Close dialog after a short delay to show loading state
                          await Future.delayed(Duration(milliseconds: 500));
                          if (mounted) Navigator.pop(context);
                        },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackbar(String message, [Color? color]) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  int _calculateCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 900) return 3;
    if (width > 600) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Campaign Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => context.read<CampaignBloc>().add(LoadCampaigns()),
            tooltip: 'Refresh Campaigns',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocConsumer<CampaignBloc, CampaignState>(
          listener: (context, state) {
            if (state is CampaignError) {
              _showSnackbar('Error: ${state.message}', Colors.red);
            } else if (state is CampaignAdded) {
              _showSnackbar('Campaign created successfully!', Colors.green);
              // Reload the campaigns after adding
              context.read<CampaignBloc>().add(LoadCampaigns());
            }
          },
          builder: (context, state) {
            if (state is CampaignLoading) {
              return const LoadingIndicator();
            } else if (state is CampaignError) {
              return ErrorDisplay(
                message: state.message,
                onRetry: () => context.read<CampaignBloc>().add(LoadCampaigns()),
              );
            } else if (state is CampaignLoaded && state.campaigns.isEmpty) {
              return const EmptyCampaignsPlaceholder();
            } else if (state is CampaignLoaded) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Active Campaigns',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'You have ${state.campaigns.length} active campaigns',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _calculateCrossAxisCount(context),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.5,
                      ),
                      itemCount: state.campaigns.length,
                      itemBuilder: (_, i) => CampaignCard(
                        campaign: state.campaigns[i],
                        onDelete: () => _showDeleteConfirmation(state.campaigns[i]),
                      ),
                    ),
                  ),
                ],
              );
            }
            return Center(child: Text('No campaigns found.'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        label: Text('New Campaign'),
        icon: Icon(Icons.add),
      ),
    );
  }

  void _showDeleteConfirmation(Campaign campaign) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Campaign'),
        content: Text('Are you sure you want to delete "${campaign.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement delete functionality in your BLoC
              // context.read<CampaignBloc>().add(DeleteCampaign(campaign.id));
              Navigator.pop(context);
              _showSnackbar('Delete functionality not implemented yet', Colors.orange);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
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
          initialDate: value ?? DateTime.now(),
          firstDate: minDate ?? DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (date != null) onSelect(date);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          value == null ? 'Select date' : formatter.format(value!),
          style: value == null
              ? TextStyle(color: Colors.grey)
              : TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}