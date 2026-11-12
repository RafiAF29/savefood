import 'package:flutter/material.dart';
import 'package:savefood/core/theme/app_theme.dart';
import 'package:savefood/features/splash/splash_screen.dart';

void main() {
  runApp(const SaveFoodApp());
}

class SaveFoodApp extends StatelessWidget {
  const SaveFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveFood',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
