import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/services/category_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';

class AdminCreateCategoryScreen extends StatefulWidget {
  const AdminCreateCategoryScreen({super.key});

  @override
  State<AdminCreateCategoryScreen> createState() =>
      _AdminCreateCategoryScreenState();
}

class _AdminCreateCategoryScreenState extends State<AdminCreateCategoryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );

    if (image != null && mounted) {
      debugPrint('========== IMAGE DEBUG ==========');
      debugPrint('Image name: ${image.name}');
      debugPrint('Image MIME type: ${image.mimeType}');
      debugPrint('Image path: ${image.path}');
      debugPrint('=================================');

      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await CategoryService.createCategory(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        image: _selectedImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Category created successfully!'),
          backgroundColor: JirisColors.primary,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
      child: Row(
        children: [
          const Text(
            'JIRIS',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 29,
              color: JirisColors.primary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: JirisColors.lavender,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'ADMIN',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: JirisColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 25, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 17,
                  color: JirisColors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Add category',
                style: TextStyle(
                  fontFamily: 'Italiana',
                  fontSize: 27,
                  color: JirisColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Create a new furniture category.',
            style: TextStyle(fontSize: 13, color: JirisColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category photo',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: JirisColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _isLoading ? null : _pickImage,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            height: 155,
            decoration: BoxDecoration(
              color: JirisColors.lavender,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: JirisColors.border, width: 0.8),
            ),
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_selectedImage!, fit: BoxFit.cover),
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 17,
                              color: JirisColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32,
                        color: JirisColors.secondary,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Add category photo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: JirisColors.primary,
                        ),
                      ),
                      SizedBox(height: 7),
                      Text(
                        'JPG or PNG · Up to 5 MB',
                        style: TextStyle(
                          fontSize: 10,
                          color: JirisColors.secondary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: JirisColors.primary,
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          enabled: !_isLoading,
          style: const TextStyle(fontSize: 13, color: JirisColors.primary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 12,
              color: JirisColors.textSecondary,
            ),
            filled: true,
            fillColor: JirisColors.surface,
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: JirisColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: JirisColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: JirisColors.primary,
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: JirisButton(
        text: 'Save Category',
        onPressed: _isLoading ? null : _saveCategory,
      ),

      // ElevatedButton(
      //   onPressed: _isLoading ? null : _saveCategory,
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: JirisColors.primary,
      //     foregroundColor: Colors.white,
      //     disabledBackgroundColor: JirisColors.secondary,
      //     elevation: 0,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(30),
      //     ),
      //   ),
      //   child: _isLoading
      //       ? const SizedBox(
      //           width: 21,
      //           height: 21,
      //           child: CircularProgressIndicator(
      //             strokeWidth: 2,
      //             color: Colors.white,
      //           ),
      //         )
      //       : const Text(
      //           'Save Category',
      //           style: TextStyle(
      //             fontSize: 13,
      //             fontWeight: FontWeight.w600,
      //           ),
      //         ),
      // ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JirisColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 25),
                  children: [
                    _buildIntroduction(),
                    _buildImagePicker(),
                    const SizedBox(height: 25),
                    _buildTextField(
                      label: 'Category name *',
                      hint: 'Enter category name',
                      controller: _nameController,
                      maxLength: 100,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Category name is required.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 17),
                    _buildTextField(
                      label: 'Description',
                      hint: 'Describe this furniture category',
                      controller: _descriptionController,
                      maxLines: 4,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 25),
                    _buildSaveButton(),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
