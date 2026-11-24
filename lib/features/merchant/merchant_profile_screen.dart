import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/features/merchant/merchant_service.dart';
import 'package:savefood/shared/widgets/sf_button.dart';
import 'package:savefood/shared/widgets/sf_text_field.dart';

class MerchantProfileScreen extends StatefulWidget {
  const MerchantProfileScreen({super.key});

  @override
  State<MerchantProfileScreen> createState() => _MerchantProfileScreenState();
}

class _MerchantProfileScreenState extends State<MerchantProfileScreen> {
  final MerchantService _service = MerchantService();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessDescController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isVerified = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _businessDescController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _service.getProfile();
      final merchant = data['merchant'];
      final profile = data['profile'];

      _nameController.text = merchant['name'] ?? '';
      _phoneController.text = merchant['phone'] ?? '';

      if (profile != null) {
        _businessNameController.text = profile['business_name'] ?? '';
        _businessDescController.text = profile['business_description'] ?? '';
        _addressController.text = profile['address'] ?? '';
        _isVerified = profile['is_verified'] ?? false;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await _service.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        businessName: _businessNameController.text.trim(),
        businessDescription: _businessDescController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        title: const Text('Merchant Profile'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.forestGreen))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Verification badge
                        if (_isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppColors.forestGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.forestGreen.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.verified,
                                    color: AppColors.forestGreen, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Your business is verified',
                                    style: TextStyle(
                                      color: AppColors.forestGreen,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Personal Info Section
                        const Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Full Name'),
                        const SizedBox(height: 8),
                        SfTextField(
                          controller: _nameController,
                          hintText: 'Your name',
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Phone Number'),
                        const SizedBox(height: 8),
                        SfTextField(
                          controller: _phoneController,
                          hintText: '08xxxxxxxxxx',
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 28),

                        // Business Info Section
                        const Text(
                          'Business Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepGreen,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Business Name'),
                        const SizedBox(height: 8),
                        SfTextField(
                          controller: _businessNameController,
                          hintText: 'Your business name',
                          validator: (v) => v == null || v.isEmpty
                              ? 'Business name is required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Business Description'),
                        const SizedBox(height: 8),
                        SfTextField(
                          controller: _businessDescController,
                          hintText: 'Tell customers about your business...',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 16),
                        _buildLabel('Pickup Address'),
                        const SizedBox(height: 8),
                        SfTextField(
                          controller: _addressController,
                          hintText: 'Business address for pickup',
                          maxLines: 2,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Address is required'
                              : null,
                        ),

                        const SizedBox(height: 32),
                        SfButton(
                          text: 'Save Changes',
                          onPressed: _save,
                          isLoading: _isSaving,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.deepGreen,
      ),
    );
  }
}
