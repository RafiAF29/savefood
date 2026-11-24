import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/core/theme/app_typography.dart';
import 'package:savefood/features/authentication/auth_service.dart';
import 'package:savefood/features/authentication/login_screen.dart';

class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        title: Text('Merchant Dashboard', style: AppTypography.headingMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store, size: 64, color: AppColors.forestGreen),
            const SizedBox(height: 16),
            Text('Welcome, Merchant!', style: AppTypography.headingLarge),
            const SizedBox(height: 8),
            Text(
              'Dashboard coming in Phase 5',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
