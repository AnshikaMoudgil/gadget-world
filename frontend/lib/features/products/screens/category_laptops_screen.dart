import 'package:flutter/material.dart';

import 'backend_category_products_screen.dart';

class CategoryLaptopsScreen extends StatelessWidget {
  const CategoryLaptopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BackendCategoryProductsScreen(
      title: 'Laptops & Tablets',
      categorySlugs: ['laptops', 'laptop-accessories'],
    );
  }
}
