import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'providers/theme_provider.dart';
import 'providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wishlist_provider.dart';

import 'services/products_service.dart';
import 'services/cart_service.dart';
import 'services/auth_service.dart';
import 'services/wishlist_service.dart';

import 'screens/root_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

        // ✅ Wishlist prati auth (uid)
        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(WishlistService()),
          update: (_, auth, wish) {
            wish ??= WishlistProvider(WishlistService());
            wish.updateAuth(auth);
            return wish;
          },
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
