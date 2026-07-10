import 'package:flutter/material.dart';
import '../core/theme.dart';

enum AddAddressState { initial, error, success }

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  AddAddressState _currentState = AddAddressState.initial;
  bool _isDefaultAddress = false;

  void _cycleState() {
    setState(() {
      if (_currentState == AddAddressState.initial) {
        _currentState = AddAddressState.error;
        _isDefaultAddress = false;
      } else if (_currentState == AddAddressState.error) {
        _currentState = AddAddressState.success;
        _isDefaultAddress = true;
      } else {
        _currentState = AddAddressState.initial;
        _isDefaultAddress = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.change_circle_outlined, color: AppTheme.greyText),
            onPressed: _cycleState,
            tooltip: 'Cycle Validation State',
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildForm(),
                const SizedBox(height: 24),
                _buildCheckbox(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Add Address', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.black)),
              SizedBox(height: 8),
              Text('Enter the details to add a new delivery address', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
            ],
          ),
        ),
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.map, size: 60, color: AppTheme.greyBorder), // Placeholder for folded map
              const Positioned(
                top: 0,
                child: Icon(Icons.location_on, size: 40, color: AppTheme.black),
              ),
              Positioned(
                bottom: 15,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.greyBorder),
                  ),
                  child: const Icon(Icons.home_outlined, size: 16, color: AppTheme.black),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final isFilled = _currentState != AddAddressState.initial;

    return Column(
      children: [
        _buildCustomField(
          label: 'Recipient Name *',
          hint: 'Enter full name',
          icon: Icons.person_outline,
          initialValue: isFilled ? 'Rohit Sharma' : '',
        ),
        const SizedBox(height: 20),
        _buildCustomField(
          label: 'Phone Number *',
          hint: 'Enter 10-digit mobile number',
          icon: Icons.phone_outlined,
          initialValue: isFilled ? '98765 43210' : '',
        ),
        const SizedBox(height: 20),
        _buildCustomField(
          label: 'Address Line 1 *',
          hint: 'House no., Building, Street, Area',
          icon: Icons.map_outlined,
          initialValue: isFilled ? '456, Lajpat Nagar, Part 2' : '',
          showCounter: true,
          maxLength: 100,
        ),
        const SizedBox(height: 20),
        _buildCustomField(
          label: 'Address Line 2 (Optional)',
          hint: 'Landmark, Nearby place, etc.',
          icon: Icons.corporate_fare_outlined,
          initialValue: isFilled ? 'Near Metro Station' : '',
          showCounter: true,
          maxLength: 100,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildCustomField(
                label: 'City *',
                hint: 'Enter city',
                icon: Icons.location_city_outlined,
                initialValue: isFilled ? 'New Delhi' : '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDropdownField(
                label: 'State *',
                hint: 'Select state',
                initialValue: isFilled ? 'Delhi' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildPincodeField(),
      ],
    );
  }

  Widget _buildCustomField({
    required String label,
    required String hint,
    required IconData icon,
    String initialValue = '',
    bool showCounter = false,
    int maxLength = 100,
  }) {
    final hasValue = initialValue.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.greyBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(icon, color: AppTheme.greyText, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  hasValue ? initialValue : hint,
                  style: TextStyle(
                    fontSize: 14,
                    color: hasValue ? AppTheme.black : AppTheme.greyText,
                  ),
                ),
              ),
              if (showCounter)
                Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Text(
                    hasValue ? '${initialValue.length}/$maxLength' : '0/$maxLength',
                    style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    String? initialValue,
  }) {
    final hasValue = initialValue != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.greyBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  hasValue ? initialValue : hint,
                  style: TextStyle(
                    fontSize: 14,
                    color: hasValue ? AppTheme.black : AppTheme.greyText,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: AppTheme.black, size: 20),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPincodeField() {
    final isError = _currentState == AddAddressState.error;
    final isSuccess = _currentState == AddAddressState.success;
    
    Color borderColor = AppTheme.greyBorder;
    if (isError) borderColor = Colors.red;
    if (isSuccess) borderColor = Colors.green;

    String value = '';
    if (isError) value = '11002';
    if (isSuccess) value = '110024';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Pincode *'),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
            color: isError ? Colors.red.shade50.withOpacity(0.3) : AppTheme.white,
          ),
          child: Row(
            children: [
              const SizedBox(width: 12),
              Icon(Icons.location_on_outlined, color: isError ? Colors.red : (isSuccess ? Colors.green : AppTheme.greyText), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value.isEmpty ? 'Enter 6-digit pincode' : value,
                  style: TextStyle(
                    fontSize: 14,
                    color: value.isEmpty ? AppTheme.greyText : AppTheme.black,
                  ),
                ),
              ),
              if (isError)
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.error_outline, color: Colors.red, size: 20),
                )
              else if (isSuccess)
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
                ),
            ],
          ),
        ),
        if (isError)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Please enter a valid 6-digit pincode', style: TextStyle(color: Colors.red, fontSize: 12)),
          )
        else if (isSuccess)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text('Looks good!', style: TextStyle(color: Colors.green, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    // Splits label to style the '*' red
    final parts = text.split('*');
    if (parts.length > 1) {
      return RichText(
        text: TextSpan(
          text: parts[0],
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black),
          children: const [
            TextSpan(
              text: '*',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      );
    }
    return Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black));
  }

  Widget _buildCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDefaultAddress = !_isDefaultAddress;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(top: 2, right: 12),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: _isDefaultAddress ? AppTheme.black : AppTheme.white,
              border: Border.all(color: _isDefaultAddress ? AppTheme.black : AppTheme.greyBorder, width: 2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: _isDefaultAddress
                ? const Icon(Icons.check, size: 14, color: AppTheme.white)
                : null,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Set as default address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
              SizedBox(height: 4),
              Text('This will be used as your primary address', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final isDisabled = _currentState == AddAddressState.error;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: const BoxDecoration(
        color: AppTheme.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isDisabled ? null : () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled ? AppTheme.greyBackground : AppTheme.black,
                foregroundColor: isDisabled ? AppTheme.greyText : AppTheme.white,
                disabledBackgroundColor: AppTheme.greyBackground,
                disabledForegroundColor: AppTheme.greyText,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, size: 20, color: isDisabled ? AppTheme.greyText : AppTheme.white),
                  const SizedBox(width: 8),
                  const Text('Save Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.shield_outlined, size: 14, color: AppTheme.greyText),
              SizedBox(width: 6),
              Text('Your data is safe and secure', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
