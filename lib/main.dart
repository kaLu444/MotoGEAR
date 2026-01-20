import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/auth_provider.dart';

import 'services/products_service.dart';
import 'services/cart_service.dart';
import 'services/auth_service.dart';

import 'screens/root_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(
          create: (_) => ProductsProvider(ProductsService())..loadProducts(),
        ),

        ChangeNotifierProvider(
          create: (_) => CartProvider(CartService())..loadCart(),
        ),

        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService())..loadSession(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          home: const RootScreen(),
        );
      },
    );
  }
}
