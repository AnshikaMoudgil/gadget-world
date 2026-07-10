import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'add_address_screen.dart';

enum AddressState { selected, unselected, empty }

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  AddressState _currentState = AddressState.selected;
  int? _selectedIndex = 0;

  final List<Map<String, String>> _addresses = [
    {
      'name': 'Aman Yadav',
      'type': 'Default',
      'address': '123, Green Park, Sector 45\nGurugram, Haryana - 122003',
      'phone': '+91 98765 43210'
    },
    {
      'name': 'Rohit Sharma',
      'type': '',
      'address': '456, Lajpat Nagar, Part 2\nNew Delhi - 110024',
      'phone': '+91 91234 56789'
    },
    {
      'name': 'Neha Verma',
      'type': '',
      'address': '78, Koramangala 5th Block\nBangalore, Karnataka - 560095',
      'phone': '+91 99876 54321'
    },
    {
      'name': 'Vikram Singh',
      'type': '',
      'address': '32, Shanti Nagar\nPune, Maharashtra - 411007',
      'phone': '+91 87654 32109'
    },
  ];

  void _cycleState() {
    setState(() {
      if (_currentState == AddressState.selected) {
        _currentState = AddressState.unselected;
        _selectedIndex = null;
      } else if (_currentState == AddressState.unselected) {
        _currentState = AddressState.empty;
        _selectedIndex = null;
      } else {
        _currentState = AddressState.selected;
        _selectedIndex = 0;
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
            tooltip: 'Cycle UI State',
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
                const SizedBox(height: 24),
                if (_currentState == AddressState.empty)
                  _buildEmptyState()
                else
                  _buildAddressList(),
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
              Text('Checkout', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.black)),
              SizedBox(height: 4),
              Text('Address', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.black)),
              SizedBox(height: 8),
              Text('Select a delivery address for your order', style: TextStyle(fontSize: 12, color: AppTheme.greyText)),
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48.0),
      child: Column(
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: AppTheme.greyBackground,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.map, size: 80, color: AppTheme.greyBorder),
                const Positioned(
                  top: 20,
                  child: Icon(Icons.location_on, size: 60, color: AppTheme.black),
                ),
                Positioned(
                  bottom: 40,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.greyBorder),
                    ),
                    child: const Icon(Icons.home_outlined, size: 20, color: AppTheme.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('No saved addresses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.black)),
          const SizedBox(height: 12),
          const Text(
            'You don\'t have any saved addresses yet.\nAdd a new address to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppTheme.greyText, height: 1.5),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.black,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('Add New Address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Saved Addresses', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.black)),
        const SizedBox(height: 16),
        ...List.generate(_addresses.length, (index) {
          final address = _addresses[index];
          final isSelected = _selectedIndex == index;
          return _buildAddressCard(address, isSelected, index);
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.black,
              side: const BorderSide(color: AppTheme.greyBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppTheme.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, size: 12, color: AppTheme.white),
                ),
                const SizedBox(width: 8),
                const Text('Add New Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard(Map<String, String> data, bool isSelected, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _currentState = AddressState.selected;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(color: isSelected ? AppTheme.black : AppTheme.greyBorder, width: isSelected ? 1.5 : 1.0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Radio Button
            Container(
              margin: const EdgeInsets.only(top: 2, right: 16),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppTheme.black : AppTheme.greyBorder, width: 2),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.black,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(data['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.black)),
                      if (data['type']!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(data['type']!, style: const TextStyle(color: AppTheme.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                      const Spacer(),
                      const Icon(Icons.more_vert, color: AppTheme.black, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(data['address']!, style: const TextStyle(color: AppTheme.greyText, fontSize: 12, height: 1.4)),
                  const SizedBox(height: 8),
                  Text(data['phone']!, style: const TextStyle(color: AppTheme.black, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final isEmpty = _currentState == AddressState.empty;
    final isUnselected = _currentState == AddressState.unselected;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: isEmpty ? null : const Border(top: BorderSide(color: AppTheme.greyBorder, width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isEmpty) ...[
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isUnselected ? null : () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUnselected ? AppTheme.greyBackground : AppTheme.black,
                  foregroundColor: isUnselected ? AppTheme.greyText : AppTheme.white,
                  disabledBackgroundColor: AppTheme.greyBackground,
                  disabledForegroundColor: AppTheme.greyText,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    if (!isUnselected) ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ] else ...[
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20, color: AppTheme.greyText),
                    ]
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
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
