
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:motogear/seeder.dart';
import 'package:motogear/services/payment_service.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'providers/theme_provider.dart';
import 'providers/products_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/navigation_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/payment_provider.dart';
import 'services/address_service.dart';
import 'providers/address_provider.dart';
import 'services/products_service.dart';
import 'services/cart_service.dart';
import 'services/auth_service.dart';
import 'services/wishlist_service.dart';
import 'providers/orders_provider.dart';
import 'services/orders_service.dart';

import 'screens/root_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        
        ChangeNotifierProvider(
          create: (_) => AuthProvider(AuthService())..loadSession(),
        ),

        
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(ProductsService())..loadProducts(),
        ),

        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(CartService()),
          update: (_, auth, cart) {
            cart ??= CartProvider(CartService());
            cart.updateAuth(auth);
            return cart;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, AddressProvider>(
          create: (_) => AddressProvider(AddressService()),
          update: (_, auth, addr) {
            addr ??= AddressProvider(AddressService());
            addr.updateAuth(auth);
            return addr;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, PaymentProvider>(
          create: (_) => PaymentProvider(PaymentService()),
          update: (_, auth, pay) {
            pay ??= PaymentProvider(PaymentService());
            pay.updateAuth(auth);
            return pay;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, WishlistProvider>(
          create: (_) => WishlistProvider(WishlistService()),
          update: (_, auth, wish) {
            wish ??= WishlistProvider(WishlistService());
            wish.updateAuth(auth);
            return wish;
          },
        ),

        ChangeNotifierProxyProvider<AuthProvider, OrdersProvider>(
          create: (_) => OrdersProvider(OrdersService()),
          update: (_, auth, ord) {
            ord ??= OrdersProvider(OrdersService());
            ord.updateAuth(auth);
            return ord;
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
