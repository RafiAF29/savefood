import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/core/constants/app_strings.dart';
import 'package:savefood/core/theme/app_typography.dart';
import 'package:savefood/core/network/api_client.dart';
import 'package:savefood/features/authentication/auth_service.dart';
import 'package:savefood/features/customer/customer_home_screen.dart';
import 'package:savefood/features/merchant/merchant_dashboard_screen.dart';
import 'package:savefood/shared/widgets/sf_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'customer';
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _businessDescController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        role: _selectedRole,
        phone: _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
        businessName: _selectedRole == 'merchant'
            ? _businessNameController.text.trim()
            : null,
        businessDescription: _selectedRole == 'merchant' &&
                _businessDescController.text.trim().isNotEmpty
            ? _businessDescController.text.trim()
            : null,
        address: _selectedRole == 'merchant' &&
                _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
      );

      if (!mounted) return;

      Widget destination;
      if (response.user.isMerchant) {
        destination = const MerchantDashboardScreen();
      } else {
        destination = const CustomerHomeScreen();
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(
          () => _errorMessage = 'Connection failed. Is the server running?');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        backgroundColor: AppColors.softCream,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                Text('Create Account', style: AppTypography.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Join SaveFood and start rescuing food',
                  style: AppTypography.bodyLarge
                      .copyWith(color: AppColors.secondaryText),
                ),
                const SizedBox(height: 32),

                // Error
                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_errorMessage!,
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.error)),
                  ),
                  const SizedBox(height: 16),
                ],

                // Role selector
                Text('I am a...', style: AppTypography.labelMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _RoleChip(
                        label: 'Customer',
                        icon: Icons.person_outline,
                        isSelected: _selectedRole == 'customer',
                        onTap: () =>
                            setState(() => _selectedRole = 'customer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleChip(
                        label: 'Merchant',
                        icon: Icons.store_outlined,
                        isSelected: _selectedRole == 'merchant',
                        onTap: () =>
                            setState(() => _selectedRole = 'merchant'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Name
                SfTextField(
                  label: AppStrings.fullName,
                  hintText: 'Enter your full name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline, size: 20),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),

                // Email
                SfTextField(
                  label: AppStrings.email,
                  hintText: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Phone
                SfTextField(
                  label: AppStrings.phone,
                  hintText: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                ),
                const SizedBox(height: 16),

                // Merchant fields
                if (_selectedRole == 'merchant') ...[
                  SfTextField(
                    label: 'Business Name',
                    hintText: 'Enter your business name',
                    controller: _businessNameController,
                    prefixIcon: const Icon(Icons.store_outlined, size: 20),
                    validator: (v) => _selectedRole == 'merchant' &&
                            (v == null || v.isEmpty)
                        ? 'Business name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  SfTextField(
                    label: 'Business Description',
                    hintText: 'Describe your business',
                    controller: _businessDescController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  SfTextField(
                    label: 'Address',
                    hintText: 'Enter your business address',
                    controller: _addressController,
                    prefixIcon:
                        const Icon(Icons.location_on_outlined, size: 20),
                  ),
                  const SizedBox(height: 16),
                ],

                // Password
                SfTextField(
                  label: AppStrings.password,
                  hintText: 'Min. 8 characters',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 8) return 'Min. 8 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm password
                SfTextField(
                  label: AppStrings.confirmPassword,
                  hintText: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppColors.white),
                          )
                        : Text(AppStrings.register,
                            style: AppTypography.button
                                .copyWith(color: AppColors.white)),
                  ),
                ),
                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppStrings.alreadyHaveAccount,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.secondaryText)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(AppStrings.login,
                          style: AppTypography.labelMedium
                              .copyWith(color: AppColors.forestGreen)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestGreen : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.forestGreen : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 20,
                color: isSelected ? AppColors.white : AppColors.secondaryText),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
