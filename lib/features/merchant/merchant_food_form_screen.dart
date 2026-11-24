import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/features/merchant/merchant_service.dart';
import 'package:savefood/features/food/food_service.dart';
import 'package:savefood/shared/models/food_model.dart';
import 'package:savefood/shared/widgets/sf_button.dart';
import 'package:savefood/shared/widgets/sf_text_field.dart';

class MerchantFoodFormScreen extends StatefulWidget {
  final FoodListingModel? food; // null = create, non-null = edit

  const MerchantFoodFormScreen({super.key, this.food});

  @override
  State<MerchantFoodFormScreen> createState() => _MerchantFoodFormScreenState();
}

class _MerchantFoodFormScreenState extends State<MerchantFoodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MerchantService _merchantService = MerchantService();
  final FoodService _foodService = FoodService();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _allergenController = TextEditingController();

  List<FoodCategoryModel> _categories = [];
  int? _selectedCategoryId;
  DateTime _pickupDeadline = DateTime.now().add(const Duration(hours: 6));
  String? _imagePath;
  bool _isLoading = false;
  bool _isCategoriesLoading = true;

  bool get _isEditing => widget.food != null;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    if (_isEditing) {
      final food = widget.food!;
      _nameController.text = food.name;
      _descriptionController.text = food.description ?? '';
      _originalPriceController.text = food.originalPrice.toStringAsFixed(0);
      _discountedPriceController.text = food.discountedPrice.toStringAsFixed(0);
      _stockController.text = food.stock.toString();
      _allergenController.text = food.allergenInfo ?? '';
      _selectedCategoryId = food.categoryId;
      _pickupDeadline = food.pickupDeadline;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _stockController.dispose();
    _allergenController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _foodService.getCategories();
      setState(() {
        _categories = cats;
        _isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() => _isCategoriesLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() => _imagePath = image.path);
    }
  }

  Future<void> _pickDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _pickupDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.forestGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_pickupDeadline),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.forestGreen,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _pickupDeadline = DateTime(
            date.year, date.month, date.day, time.hour, time.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final deadline = _pickupDeadline.toUtc().toIso8601String();

      if (_isEditing) {
        await _merchantService.updateFood(
          id: widget.food!.id,
          categoryId: _selectedCategoryId,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          originalPrice: double.parse(_originalPriceController.text),
          discountedPrice: double.parse(_discountedPriceController.text),
          stock: int.parse(_stockController.text),
          allergenInfo: _allergenController.text.trim().isEmpty
              ? null
              : _allergenController.text.trim(),
          pickupDeadline: deadline,
          imagePath: _imagePath,
        );
      } else {
        await _merchantService.createFood(
          categoryId: _selectedCategoryId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          originalPrice: double.parse(_originalPriceController.text),
          discountedPrice: double.parse(_discountedPriceController.text),
          stock: int.parse(_stockController.text),
          allergenInfo: _allergenController.text.trim().isEmpty
              ? null
              : _allergenController.text.trim(),
          pickupDeadline: deadline,
          imagePath: _imagePath,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Listing updated!' : 'Listing created!',
            ),
          ),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Listing' : 'Add New Listing'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
      ),
      body: _isCategoriesLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.forestGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image picker
                    _buildImagePicker(),
                    const SizedBox(height: 20),

                    // Category
                    _buildLabel('Category'),
                    const SizedBox(height: 8),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 16),

                    // Name
                    _buildLabel('Food Name'),
                    const SizedBox(height: 8),
                    SfTextField(
                      controller: _nameController,
                      hintText: 'e.g. Croissant Pack (3 pcs)',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Description
                    _buildLabel('Description'),
                    const SizedBox(height: 8),
                    SfTextField(
                      controller: _descriptionController,
                      hintText: 'Describe the food...',
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // Prices
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Original Price'),
                              const SizedBox(height: 8),
                              SfTextField(
                                controller: _originalPriceController,
                                hintText: '45000',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Discounted Price'),
                              const SizedBox(height: 8),
                              SfTextField(
                                controller: _discountedPriceController,
                                hintText: '20000',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Required'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Stock
                    _buildLabel('Stock'),
                    const SizedBox(height: 8),
                    SfTextField(
                      controller: _stockController,
                      hintText: '5',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Stock is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // Allergen info
                    _buildLabel('Allergen Info (optional)'),
                    const SizedBox(height: 8),
                    SfTextField(
                      controller: _allergenController,
                      hintText: 'e.g. Contains: wheat, dairy, eggs',
                    ),
                    const SizedBox(height: 16),

                    // Pickup deadline
                    _buildLabel('Pickup Deadline'),
                    const SizedBox(height: 8),
                    _buildDeadlinePicker(),
                    const SizedBox(height: 32),

                    // Submit
                    SfButton(
                      text: _isEditing ? 'Update Listing' : 'Create Listing',
                      onPressed: _submit,
                      isLoading: _isLoading,
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

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: _imagePath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_imagePath!),
                  fit: BoxFit.cover,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined,
                      size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add photo',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  Text(
                    'JPEG or PNG, max 2 MB',
                    style: TextStyle(color: Colors.grey[400], fontSize: 11),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCategoryId,
          isExpanded: true,
          hint: Text(
            'Select category',
            style: TextStyle(color: Colors.grey[400]),
          ),
          items: _categories.map((cat) {
            return DropdownMenuItem<int>(
              value: cat.id,
              child: Text(cat.name),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedCategoryId = value);
          },
        ),
      ),
    );
  }

  Widget _buildDeadlinePicker() {
    return GestureDetector(
      onTap: _pickDeadline,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.forestGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_pickupDeadline.day}/${_pickupDeadline.month}/${_pickupDeadline.year}  '
                '${_pickupDeadline.hour.toString().padLeft(2, '0')}:'
                '${_pickupDeadline.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Icon(Icons.edit_calendar, color: Colors.grey[400], size: 20),
          ],
        ),
      ),
    );
  }
}
