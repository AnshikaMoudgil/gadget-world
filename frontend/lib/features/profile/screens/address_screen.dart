import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/profile/screens/add_address_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  bool _isEmptyState = false;

  final List<Map<String, dynamic>> _addresses = [
    {
      'type': 'Home',
      'icon': Icons.home_outlined,
      'name': 'Rohit Sharma',
      'isDefault': true,
      'address': '456, Lajpat Nagar Part 2,\nNear Metro Station, New Delhi - 110024\nDelhi, India\nPhone: +91 98765 43210'
    },
    {
      'type': 'Office',
      'icon': Icons.business_center_outlined,
      'name': 'Office',
      'isDefault': false,
      'address': '7th Floor, Tower B,\nSector 62, Noida - 201301\nUttar Pradesh, India\nPhone: +91 91234 56789'
    },
    {
      'type': 'Home',
      'icon': Icons.home_outlined,
      'name': 'Home',
      'isDefault': false,
      'address': '89, Green Park Extension,\nGreen Park, New Delhi - 110016\nDelhi, India\nPhone: +91 99887 76655'
    },
  ];

  void _toggleState() {
    setState(() {
      _isEmptyState = !_isEmptyState;
    });
  }

  void _showDeleteConfirmation() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppTheme.greyBorder, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
              ),
              const SizedBox(height: 16),
              const Text('Delete Address?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.black)),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to delete this address?\nThis action cannot be undone.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.greyText, height: 1.4),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.black,
                        side: const BorderSide(color: AppTheme.greyBorder),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.black,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Delete', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    _isEmptyState ? _buildEmptyState() : _buildAddressList(),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
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
                              Icon(Icons.add_circle_outline, size: 20),
                              SizedBox(width: 8),
                              Text('Add New Address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, size: 20),
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
                  Text('My Addresses', style: TextStyle(color: AppTheme.black, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Manage your saved addresses', style: TextStyle(color: AppTheme.greyText, fontSize: 12)),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.change_circle_outlined, color: AppTheme.greyText),
            onPressed: _toggleState,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAddressScreen()));
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: AppTheme.black, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.add, color: AppTheme.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 100.0),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppTheme.greyBackground.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: const [
                  Icon(Icons.map, size: 80, color: AppTheme.white),
                  Positioned(
                    top: 20,
                    child: Icon(Icons.location_on, size: 60, color: AppTheme.black),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('No addresses yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.black)),
            const SizedBox(height: 12),
            const Text(
              'Add an address to make your\ncheckout experience faster.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.greyText, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList() {
    return Column(
      children: _addresses.map((address) => _buildAddressCard(address)).toList(),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> data) {
    final isDefault = data['isDefault'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border.all(color: AppTheme.greyBorder.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: AppTheme.black, borderRadius: BorderRadius.circular(10)),
                  child: Icon(data['icon'], color: AppTheme.white, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(data['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.black)),
                          if (isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AppTheme.black, borderRadius: BorderRadius.circular(6)),
                              child: const Text('Default', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppTheme.white)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(data['address'], style: const TextStyle(fontSize: 12, color: AppTheme.greyText, height: 1.5)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.greyBorder),
                        ),
                        child: const Icon(Icons.edit_outlined, size: 14, color: AppTheme.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _showDeleteConfirmation,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.greyBorder),
                        ),
                        child: const Icon(Icons.delete_outline, size: 14, color: AppTheme.black),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isDefault) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.greyBackground.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.star, size: 14, color: AppTheme.black),
                  SizedBox(width: 8),
                  Text('Default shipping address', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.greyText)),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}
