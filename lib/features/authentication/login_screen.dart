import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/core/theme/app_typography.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: Center(
        child: Text(
          'Login Screen\n(Coming in Phase 3)',
          textAlign: TextAlign.center,
          style: AppTypography.headingMedium,
        ),
      ),
    );
  }
}
