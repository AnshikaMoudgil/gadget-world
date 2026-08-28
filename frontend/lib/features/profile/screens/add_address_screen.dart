import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/profile/providers/address_provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:gadget_store/features/profile/models/address.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? address;

  const AddAddressScreen({super.key, this.address});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedType = 'home';
  bool _isDefault = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _landmarkController = TextEditingController();

  bool get _isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    if (address == null) return;
    _selectedType = address.addressType.name;
    _isDefault = address.isDefault;
    _nameController.text = address.recipientName;
    _phoneController.text = address.phoneNumber;
    _pincodeController.text = address.postalCode;
    _addressLine1Controller.text = address.addressLine1;
    _addressLine2Controller.text = address.addressLine2 ?? '';
    _cityController.text = address.city;
    _stateController.text = address.state;
    _landmarkController.text = address.landmark ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pincodeController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<AddressProvider>(context, listen: false);

    final data = {
      'recipient_name': _nameController.text.trim(),
      'phone_number': _phoneController.text.trim(),
      'postal_code': _pincodeController.text.trim(),
      'address_line1': _addressLine1Controller.text.trim(),
      'address_line2': _addressLine2Controller.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'landmark': _landmarkController.text.trim(),
      'address_type': _selectedType,
      'is_default': _isDefault,
    };

    try {
      if (_isEditing) {
        await provider.updateAddress(widget.address!.id!, data);
      } else {
        await provider.createAddress(data);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'Address updated successfully!'
                  : 'Address saved successfully!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save address: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AddressProvider>(context).isLoading;

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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Address Type',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildTypeChip('home', 'Home', Icons.home),
                              const SizedBox(width: 12),
                              _buildTypeChip(
                                'work',
                                'Office',
                                Icons.business_center_outlined,
                              ),
                              const SizedBox(width: 12),
                              _buildTypeChip(
                                'other',
                                'Other',
                                Icons.location_on_outlined,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildLabel('Full Name'),
                          _buildTextField(
                            controller: _nameController,
                            hintText: 'Enter full name',
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Phone Number'),
                          _buildTextField(
                            controller: _phoneController,
                            hintText: 'Enter phone number',
                            keyboardType: TextInputType.phone,
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Pincode'),
                          _buildTextField(
                            controller: _pincodeController,
                            hintText: 'Enter pincode',
                            keyboardType: TextInputType.number,
                            trailingIcon: PhosphorIcons.magnifyingGlass,
                            validator: (val) {
                              if (val == null || val.isEmpty) return 'Required';
                              if (!RegExp(r'^[1-9][0-9]{5}$').hasMatch(val)) {
                                return 'Invalid PIN code';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Address Line 1'),
                          _buildTextField(
                            controller: _addressLine1Controller,
                            hintText: 'House no., Building, Street',
                            validator: (val) =>
                                val == null || val.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Address Line 2 (Optional)'),
                          _buildTextField(
                            controller: _addressLine2Controller,
                            hintText: 'Area, Locality',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('City'),
                                    _buildTextField(
                                      controller: _cityController,
                                      hintText: 'Enter city',
                                      validator: (val) =>
                                          val == null || val.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildLabel('State'),
                                    _buildTextField(
                                      controller: _stateController,
                                      hintText: 'Enter state',
                                      validator: (val) =>
                                          val == null || val.isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildLabel('Landmark (Optional)'),
                          _buildTextField(
                            controller: _landmarkController,
                            hintText: 'E.g. Near Apollo Hospital',
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Checkbox(
                                value: _isDefault,
                                onChanged: (val) {
                                  setState(() {
                                    _isDefault = val ?? false;
                                  });
                                },
                                activeColor: AppTheme.black,
                              ),
                              const Text('Set as default address'),
                            ],
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: isLoading ? null : _saveAddress,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.black,
                              foregroundColor: AppTheme.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (isLoading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                else ...[
                                  const Icon(Icons.save_outlined, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Save Address',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
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
            icon: const Icon(PhosphorIcons.arrowLeft, color: AppTheme.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
              ), // Align text baseline with icon
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Add New Address',
                    style: TextStyle(
                      color: AppTheme.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add a new shipping address',
                    style: TextStyle(color: AppTheme.greyText, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String value, String label, IconData icon) {
    final isSelected = _selectedType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.black : AppTheme.white,
          border: Border.all(
            color: isSelected ? AppTheme.black : AppTheme.greyBorder,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppTheme.white : AppTheme.greyText,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppTheme.white : AppTheme.greyText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? trailingIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.greyText, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: AppTheme.greyBackground.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.black, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        suffixIcon: trailingIcon != null
            ? Icon(trailingIcon, color: AppTheme.greyText, size: 20)
            : null,
      ),
    );
  }
}
