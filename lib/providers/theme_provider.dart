import 'package:flutter/material.dart';
import '../consts/theme_data.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData get themeData => AppThemeData.darkTheme();

  
}
