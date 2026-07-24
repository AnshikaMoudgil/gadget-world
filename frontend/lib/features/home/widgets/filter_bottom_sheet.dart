import 'package:flutter/material.dart';
import 'package:gadget_store/core/theme.dart';
import 'package:gadget_store/features/products/providers/catalog_provider.dart';
import 'package:provider/provider.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  // Local state for the filter panel
  double _minPrice = 0;
  double _maxPrice = 20000;
  String _selectedBrand = 'All';
  String _selectedAvailability = 'All';
  String _selectedSort = 'newest';

  final List<String> _brands = [
    'All',
    'Apple',
    'Sony',
    'Samsung',
    'JBL',
    'boAt',
    'MI',
    'Realme',
  ];

  @override
  void initState() {
    super.initState();
    final provider = context.read<CatalogProvider>();
    _minPrice = provider.minPrice ?? 0;
    _maxPrice = provider.maxPrice ?? 20000;
    _selectedBrand = provider.filterBrandId ?? 'All';
    if (provider.inStock == true) _selectedAvailability = 'In Stock';
    if (provider.inStock == false) _selectedAvailability = 'Out of Stock';
    _selectedSort = provider.sortBy ?? 'newest';
  }

  void _applyFilters() {
    final provider = context.read<CatalogProvider>();
    provider.setFilters(
      minPrice: _minPrice > 0 ? _minPrice : null,
      maxPrice: _maxPrice < 20000 ? _maxPrice : null,
      brandId: _selectedBrand,
      inStock: _selectedAvailability == 'All'
          ? null
          : _selectedAvailability == 'In Stock',
      sortBy: _selectedSort,
    );
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice = 20000;
      _selectedBrand = 'All';
      _selectedAvailability = 'All';
      _selectedSort = 'newest';
    });
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onClear}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          if (onClear != null)
            TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: AppTheme.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, Function(bool) onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: AppTheme.white,
      selectedColor: AppTheme.black,
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.white : AppTheme.black,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.black : AppTheme.greyBorder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.greyBorder),

          // Scrollable Content
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Range
                  _buildSectionHeader(
                    'Price Range',
                    onClear: () {
                      setState(() {
                        _minPrice = 0;
                        _maxPrice = 20000;
                      });
                    },
                  ),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: 20000,
                    divisions: 20,
                    activeColor: AppTheme.black,
                    inactiveColor: AppTheme.greyBorder,
                    labels: RangeLabels(
                      '₹${_minPrice.toInt()}',
                      _maxPrice == 20000 ? '₹20,000+' : '₹${_maxPrice.toInt()}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${_minPrice.toInt()}',
                        style: const TextStyle(color: AppTheme.greyText),
                      ),
                      Text(
                        _maxPrice == 20000
                            ? '₹20,000+'
                            : '₹${_maxPrice.toInt()}',
                        style: const TextStyle(color: AppTheme.greyText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Brand
                  _buildSectionHeader(
                    'Brand',
                    onClear: () => setState(() => _selectedBrand = 'All'),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _brands.map((brand) {
                      return _buildChip(brand, _selectedBrand == brand, (
                        selected,
                      ) {
                        if (selected) setState(() => _selectedBrand = brand);
                      });
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Availability
                  _buildSectionHeader(
                    'Availability',
                    onClear: () =>
                        setState(() => _selectedAvailability = 'All'),
                  ),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'In Stock', 'Out of Stock'].map((
                      availability,
                    ) {
                      return _buildChip(
                        availability,
                        _selectedAvailability == availability,
                        (selected) {
                          if (selected)
                            setState(
                              () => _selectedAvailability = availability,
                            );
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Sort By
                  _buildSectionHeader('Sort By'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChip('Popular', _selectedSort == 'popular', (s) {
                        if (s) setState(() => _selectedSort = 'popular');
                      }),
                      _buildChip(
                        'Price: Low to High',
                        _selectedSort == 'price_asc',
                        (s) {
                          if (s) setState(() => _selectedSort = 'price_asc');
                        },
                      ),
                      _buildChip(
                        'Price: High to Low',
                        _selectedSort == 'price_desc',
                        (s) {
                          if (s) setState(() => _selectedSort = 'price_desc');
                        },
                      ),
                      _buildChip('Newest First', _selectedSort == 'newest', (
                        s,
                      ) {
                        if (s) setState(() => _selectedSort = 'newest');
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions
          const Divider(height: 1, color: AppTheme.greyBorder),
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              16,
              24,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.black,
                      side: const BorderSide(color: AppTheme.greyBorder),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.black,
                      foregroundColor: AppTheme.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
