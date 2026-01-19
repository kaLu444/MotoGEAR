import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart';
import 'home_screen.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  static const List<Widget> _pages = [
    HomeScreen(),
    CategoriesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      body: IndexedStack(index: nav.index, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: nav.index,
        onTap: (i) => context.read<NavigationProvider>().setIndex(i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
