import 'package:flutter/material.dart';
import 'package:gadget_world/core/theme.dart';
import 'package:gadget_world/features/home/screens/home_screen.dart';
import 'package:gadget_world/features/checkout/screens/cart_screen.dart';
import 'package:gadget_world/features/profile/screens/profile_screen.dart';
import 'package:gadget_world/features/orders/screens/orders_screen.dart';
import 'package:gadget_world/features/products/screens/categories_screen.dart';
import 'package:provider/provider.dart';
import 'package:gadget_world/features/cart/providers/cart_provider.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const CategoriesScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.greyBorder, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.house),
              activeIcon: Icon(PhosphorIcons.houseFill),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.squaresFour),
              activeIcon: Icon(PhosphorIcons.squaresFourFill),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(PhosphorIcons.shoppingCart),
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      if (cartProvider.itemCount == 0) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppTheme.black,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${cartProvider.itemCount}',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              activeIcon: Stack(
                children: [
                  const Icon(PhosphorIcons.shoppingCartFill),
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      if (cartProvider.itemCount == 0) {
                        return const SizedBox.shrink();
                      }
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: AppTheme.black,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 14,
                            minHeight: 14,
                          ),
                          child: Text(
                            '${cartProvider.itemCount}',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              label: 'Cart',
            ),
            const BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.receipt),
              activeIcon: Icon(PhosphorIcons.receiptFill),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(PhosphorIcons.user),
              activeIcon: Icon(PhosphorIcons.userFill),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }
}
