import 'package:flutter/material.dart';
import 'package:motogear/services/products_service.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'providers/products_provider.dart';

import 'screens/root_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(
          create: (_) => ProductsProvider(ProductsService())..loadProducts(),
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

