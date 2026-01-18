import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'screens/root_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MotoGEAR - Alpinestars',
            theme: themeProvider.themeData,
            home: const RootScreen(),
          );
        },
      ),
    );
  }
}
