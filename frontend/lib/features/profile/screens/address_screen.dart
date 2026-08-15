import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gadget_world/core/theme.dart';
import 'package:gadget_world/features/profile/screens/add_address_screen.dart';
import 'package:gadget_world/features/profile/providers/address_provider.dart';
import 'package:gadget_world/features/profile/models/address.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class AddressScreen extends StatefulWidget {
  final bool isCheckout;

  const AddressScreen({super.key, this.isCheckout = false});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  Address? _selectedAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AddressProvider>(context, listen: false).fetchAddresses();
    });
  }

  void _showOptions(Address address) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.greyBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.star_border, color: AppTheme.black),
                title: const Text('Set as Default'),
                onTap: () {
                  Navigator.pop(context);
                  _setDefault(address);
                },
              ),
              ListTile(
                leading: const Icon(PhosphorIcons.trash, color: Colors.red),
                title: const Text(
                  'Delete Address',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAddress(address);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setDefault(Address address) async {
    try {
      await Provider.of<AddressProvider>(
        context,
        listen: false,
      ).setDefaultAddress(address.id!);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Address set as default')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  Future<void> _deleteAddress(Address address) async {
    try {
      await Provider.of<AddressProvider>(
        context,
        listen: false,
      ).deleteAddress(address.id!);
      if (_selectedAddress?.id == address.id) {
        setState(() => _selectedAddress = null);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Address deleted')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    }
  }

  Widget _buildTopGraphic() {
    return SizedBox(
      width: 70,
      height: 70,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(Icons.map, size: 60, color: Colors.grey.shade300),
          ),
          const Positioned(
            right: 20,
            top: -5,
            child: Icon(Icons.location_on, size: 40, color: AppTheme.black),
          ),
          Positioned(
            right: 0,
            top: 15,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.black, width: 1.5),
              ),
              child: const Icon(
                Icons.home_outlined,
                size: 14,
                color: AppTheme.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isCheckout) ...[
                  const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                const Text(
                  'Address',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.isCheckout
                      ? 'Select a delivery address for your order'
                      : 'Manage your saved addresses',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.greyText,
                  ),
                ),
              ],
            ),
          ),
          _buildTopGraphic(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade50,
                    ),
                  ),
                  Positioned(
                    bottom: 25,
                    child: Icon(
                      Icons.map,
                      size: 130,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  const Positioned(
                    top: 25,
                    child: Icon(
                      Icons.location_on,
                      size: 80,
                      color: AppTheme.black,
                    ),
                  ),
                  Positioned(
                    right: 35,
                    bottom: 45,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home,
                        size: 18,
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No saved addresses',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You don\'t have any saved addresses yet.\nAdd a new address to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.greyText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Address address) {
    final isDefault = address.isDefault;
    final isSelected = widget.isCheckout
        ? _selectedAddress != null && _selectedAddress!.id == address.id
        : isDefault; // In profile mode, 'selected' means default

    return GestureDetector(
      onTap: () {
        if (widget.isCheckout) {
          setState(() => _selectedAddress = address);
        } else if (!isDefault) {
          _setDefault(address);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: Border.all(
            color: isSelected
                ? AppTheme.black
                : AppTheme.greyBorder.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 2),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.black : AppTheme.greyBorder,
                  width: isSelected ? 6 : 1,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.recipientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.black,
                        ),
                      ),
                      if (isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Default',
                            style: TextStyle(
                              fontSize: 9,
                              color: AppTheme.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.greyText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.phoneNumber,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.greyText,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showOptions(address),
              child: const Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(
                  PhosphorIcons.dotsThreeVertical,
                  size: 20,
                  color: AppTheme.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrowLeft, color: AppTheme.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<AddressProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.addresses.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.black),
            );
          }

          final bool hasAddresses = provider.addresses.isNotEmpty;

          return Column(
            children: [
              if (hasAddresses)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        if (widget.isCheckout)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Saved Addresses',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.black,
                              ),
                            ),
                          ),
                        ...provider.addresses
                            .map((a) => _buildAddressCard(a))
                            ,
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddAddressScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.white,
                              border: Border.all(color: AppTheme.greyBorder),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_box,
                                  size: 20,
                                  color: AppTheme.black,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add New Address',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                )
              else ...[
                _buildHeader(),
                _buildEmptyState(),
              ],

              // Bottom Action Area
              Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(color: AppTheme.white),
                child: SafeArea(
                  child: Column(
                    children: [
                      if (!hasAddresses)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddAddressScreen(),
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.add_box_outlined,
                                  size: 20,
                                  color: AppTheme.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add New Address',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (hasAddresses && widget.isCheckout)
                        GestureDetector(
                          onTap: _selectedAddress == null
                              ? null
                              : () => Navigator.pop(context, _selectedAddress),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: _selectedAddress == null
                                  ? AppTheme.greyBorder
                                  : AppTheme.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                'Continue',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: _selectedAddress == null
                                      ? AppTheme.greyText
                                      : AppTheme.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: AppTheme.greyText,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Your data is safe and secure',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.greyText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
