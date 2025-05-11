import 'package:flutter/material.dart';

class ProvinceDropdown extends StatelessWidget {
  final String selectedProvince;
  final ValueChanged<String> onProvinceSelected;
  final FocusNode focusNode;
  final bool isFocused;

  const ProvinceDropdown({
    super.key,
    required this.selectedProvince,
    required this.onProvinceSelected,
    required this.focusNode,
    required this.isFocused,
  });

  @override
  Widget build(BuildContext context) {
    final provinces = [
      'Gauteng',
      'KwaZulu-Natal',
      'Western Cape',
      'Eastern Cape',
      'Free State',
      'Limpopo',
      'Mpumalanga',
      'Northern Cape',
      'North West',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Province',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isFocused ? FontWeight.w600 : FontWeight.w500,
            color: isFocused
                ? Theme.of(context).primaryColor
                : Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedProvince.isEmpty ? null : selectedProvince,
          focusNode: focusNode,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          hint: const Text("Select a province"),
          items: provinces.map((province) {
            return DropdownMenuItem<String>(
              value: province,
              child: Text(province),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onProvinceSelected(value);
            }
          },
          validator: (value) => value == null || value.isEmpty
              ? 'Please select a province'
              : null,
        ),
      ],
    );
  }
}
