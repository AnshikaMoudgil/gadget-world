import 'package:flutter/material.dart';

import 'backend_category_products_screen.dart';

class CategoryMobilesScreen extends StatelessWidget {
  const CategoryMobilesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BackendCategoryProductsScreen(
      title: 'Mobile Phones',
      categorySlugs: ['mobiles', 'mobile-accessories'],
    );
  }
}
