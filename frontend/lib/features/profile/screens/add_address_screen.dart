import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  String _selectedType = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Address Type', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildTypeChip('Home', Icons.home),
                            const SizedBox(width: 12),
                            _buildTypeChip('Office', Icons.business_center_outlined),
                            const SizedBox(width: 12),
                            _buildTypeChip('Other', Icons.location_on_outlined),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildLabel('Full Name'),
                        _buildTextField('Enter full name'),
                        const SizedBox(height: 16),
                        _buildLabel('Phone Number'),
                        _buildTextField('Enter phone number'),
                        const SizedBox(height: 16),
                        _buildLabel('Pincode'),
                        _buildTextField('Enter pincode', trailingIcon: Icons.search),
                        const SizedBox(height: 16),
                        _buildLabel('Address Line 1'),
                        _buildTextField('House no., Building, Street'),
                        const SizedBox(height: 16),
                        _buildLabel('Address Line 2 (Optional)'),
                        _buildTextField('Landmark, Area, Locality'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('City'),
                                  _buildTextField('Enter city'),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('State'),
                                  _buildTextField('Select state', trailingIcon: Icons.keyboard_arrow_down),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Address Label (Optional)'),
                        _buildTextField('E.g. Home, Office'),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.black,
                            foregroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.save_outlined, size: 20),
                                  SizedBox(width: 8),
                                  Text('Save Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0), // Align text baseline with icon
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Add New Address', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Add a new shipping address', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon) {
    final isSelected = _selectedType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.black : AppTheme.white,
          border: Border.all(color: isSelected ? AppTheme.black : AppTheme.greyBorder.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? AppTheme.white : AppTheme.black),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppTheme.white : AppTheme.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.black)),
    );
  }

  Widget _buildTextField(String hint, {IconData? trailingIcon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.greyText, fontSize: 12),
          suffixIcon: trailingIcon != null ? Icon(trailingIcon, color: AppTheme.black, size: 20) : null,
          suffixIconConstraints: trailingIcon != null ? const BoxConstraints(minWidth: 40) : null,
        ),
        style: const TextStyle(fontSize: 14, color: AppTheme.black),
      ),
    );
  }
}
