import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smartmedia_campaign_manager/core/utils/colors.dart';
import 'package:smartmedia_campaign_manager/features/stores/presentation/widgets/add%20store/province_dropdown.dart';

class StoreFormFields extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController siteNumberController;
  final TextEditingController tillCountController;
  final String selectedRegion;
  final Function(String) onRegionSelected;

  const StoreFormFields({
    super.key,
    required this.nameController,
    required this.siteNumberController,
    required this.tillCountController,
    required this.selectedRegion,
    required this.onRegionSelected,
  });

  @override
  State<StoreFormFields> createState() => _StoreFormFieldsState();
}

class _StoreFormFieldsState extends State<StoreFormFields> {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    for (var node in _focusNodes) {
      node.addListener(() {
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   

    return Column(
      children: [
        _buildTextField(
          controller: widget.nameController,
          focusNode: _focusNodes[0],
          label: 'Store Name',
          icon: Icons.error_outline_rounded,
          hint: 'eg shoprite',
          validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
          delay: 0,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: ProvinceDropdown(
            selectedProvince: widget.selectedRegion,
            onProvinceSelected: widget.onRegionSelected,
            focusNode: _focusNodes[1],
            isFocused: _focusNodes[1].hasFocus,
          ),
        ).animate().fadeIn(delay: const Duration(milliseconds: 100)).slideX(
              begin: 0.05,
              end: 0,
              delay: const Duration(milliseconds: 100),
            ),
        _buildTextField(
          controller: widget.siteNumberController,
          focusNode: _focusNodes[2],
          label: 'Site Number',
          icon: Icons.tag_rounded,
          hint: 'e.g., S425',
          validator: (value) =>
              value!.isEmpty ? 'Please enter a site number' : null,
          delay: 200,
        ),
        _buildTextField(
          controller: widget.tillCountController,
          focusNode: _focusNodes[3],
          label: 'Number of Tills',
          icon: Icons.point_of_sale_rounded,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value!.isEmpty) return 'Please enter till count';
            final count = int.tryParse(value);
            if (count == null || count <= 0) {
              return 'Please enter a valid number';
            }
            return null;
          },
          delay: 300,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required FormFieldValidator<String> validator,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    required int delay,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final isFocused = focusNode.hasFocus;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isFocused ? FontWeight.w600 : FontWeight.w500,
              color: isFocused
                  ? colorScheme.primary
                  : theme.textTheme.bodyMedium!.color!.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            validator: validator,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade400,
                fontSize: 14,
              ),
              filled: true,
              fillColor:
                  isDarkMode ? AppColors.cardColorDark : colorScheme.surface,
              prefixIcon: Icon(
                icon,
                color: isFocused
                    ? colorScheme.primary
                    : theme.iconTheme.color?.withOpacity(0.6),
                size: 20,
              ).animate(target: isFocused ? 1 : 0).scaleXY(
                    begin: 1,
                    end: 1.2,
                    duration: const Duration(milliseconds: 200),
                  ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color:
                      isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade300),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.05, end: 0, delay: Duration(milliseconds: delay));
  }
}
