import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/services/product_service.dart';
import 'package:mobile/services/category_service.dart';
import 'package:mobile/services/company_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';

class AdminCreateProductScreen extends StatefulWidget {
  const AdminCreateProductScreen({super.key});

  @override
  State<AdminCreateProductScreen> createState() =>
      _AdminCreateProductScreenState();
}

class _AdminCreateProductScreenState extends State<AdminCreateProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImage;

  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _companies = [];

  int? _selectedCategoryId;
  int? _selectedCompanyId;

  String _selectedStatus = 'published';

  bool _isLoading = false;
  bool _isLoadingOptions = true;

  String? _optionsError;

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      _isLoadingOptions = true;
      _optionsError = null;
    });

    try {
      final results = await Future.wait([
        CategoryService.getCategories(),
        CompanyService.getCompanies(),
      ]);

      if (!mounted) return;

      setState(() {
        _categories = results[0]
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        _companies = results[1]
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        _isLoadingOptions = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _optionsError = error.toString();
        _isLoadingOptions = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (image == null || !mounted) return;

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $error')));
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null || _selectedCompanyId == null) {
      _showMessage('Silakan pilih kategori dan perusahaan.');
      return;
    }

    final price = double.tryParse(_priceController.text.trim());

    final stock = int.tryParse(_stockController.text.trim());

    if (price == null || price <= 0) {
      _showMessage('Harga produk tidak valid.');
      return;
    }

    if (stock == null || stock < 0) {
      _showMessage('Jumlah stok tidak valid.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ProductService.createProduct(
        productData: {
          'name': _nameController.text.trim(),
          'category_id': _selectedCategoryId,
          'company_id': _selectedCompanyId,
          'description': _descriptionController.text.trim(),
          'price': price,
          'stock': stock,
          'status': _selectedStatus,
        },
        image: _selectedImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan.')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showMessage('Gagal menambahkan produk: $error', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : JirisColors.primary,
      ),
    );
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
      padding: const EdgeInsets.fromLTRB(0, 25, 0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                'Add product',
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
            'Add a new furniture product to your catalog.',
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
          'Product image',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: JirisColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: _isLoading ? null : _pickImage,
          child: Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: JirisColors.lavender,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: JirisColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: _selectedImage != null
                ? Stack(
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
                  )
                : _imagePlaceholder(),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap the image to choose a product photo.',
          style: TextStyle(fontSize: 10, color: JirisColors.textSecondary),
        ),
      ],
    );
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 38,
            color: JirisColors.secondary,
          ),
          SizedBox(height: 8),
          Text(
            'Choose product image',
            style: TextStyle(fontSize: 11, color: JirisColors.secondary),
          ),
          SizedBox(height: 7),
          Text(
            'JPG, PNG, or WEBP · Up to 5 MB',
            style: TextStyle(fontSize: 10, color: JirisColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: JirisColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
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
            contentPadding: const EdgeInsets.all(14),
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
              borderSide: const BorderSide(color: JirisColors.primary),
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

  Widget _buildDropdowns() {
    if (_isLoadingOptions) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: CircularProgressIndicator(color: JirisColors.primary),
        ),
      );
    }

    if (_optionsError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _optionsError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
          TextButton.icon(
            onPressed: _isLoading ? null : _loadDropdownData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry loading categories and companies'),
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildDropdown(
          label: 'Category',
          hint: 'Select product category',
          value: _selectedCategoryId,
          items: _categories,
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
        ),
        const SizedBox(height: 18),
        _buildDropdown(
          label: 'Company',
          hint: 'Select company',
          value: _selectedCompanyId,
          items: _companies,
          onChanged: (value) {
            setState(() {
              _selectedCompanyId = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required int? value,
    required List<Map<String, dynamic>> items,
    required ValueChanged<int?> onChanged,
  }) {
    final validValue = items.any((item) => _toInt(item['id']) == value)
        ? value
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: JirisColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          value: validValue,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: JirisColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 5,
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
              borderSide: const BorderSide(color: JirisColors.primary),
            ),
          ),
          hint: Text(hint, style: const TextStyle(fontSize: 12)),
          items: items.map((item) {
            return DropdownMenuItem<int>(
              value: _toInt(item['id']),
              child: Text(
                item['name']?.toString() ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: JirisColors.primary,
                ),
              ),
            );
          }).toList(),
          onChanged: _isLoading ? null : onChanged,
          validator: (selected) {
            if (selected == null) {
              return 'This field is required.';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Product status',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: JirisColors.primary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildStatusOption('published', 'Published')),
            const SizedBox(width: 10),
            Expanded(child: _buildStatusOption('draft', 'Draft')),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusOption(String value, String label) {
    final selected = _selectedStatus == value;

    return GestureDetector(
      onTap: _isLoading
          ? null
          : () {
              setState(() {
                _selectedStatus = value;
              });
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: selected ? JirisColors.primary : JirisColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? JirisColors.primary : JirisColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : JirisColors.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: JirisButton(
        text: 'Save Poduct',
        onPressed: _isLoading ? null : _saveProduct,
      ),

      // ElevatedButton(
      //   onPressed: _isLoading || _isLoadingOptions ? null : _saveProduct,
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
      //           width: 20,
      //           height: 20,
      //           child: CircularProgressIndicator(
      //             strokeWidth: 2,
      //             color: Colors.white,
      //           ),
      //         )
      //       : const Text(
      //           'Save Product',
      //           style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      //         ),
      // ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();

    super.dispose();
  }

  // BUILD
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
                      label: 'Product name',
                      hint: 'Enter product name',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Product name is required.';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildDropdowns(),

                    const SizedBox(height: 18),

                    _buildTextField(
                      label: 'Description',
                      hint: 'Enter product description',
                      controller: _descriptionController,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 18),

                    _buildTextField(
                      label: 'Price (Rp)',
                      hint: 'Enter product price',
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) {
                        final price = double.tryParse(value?.trim() ?? '');

                        if (price == null || price <= 0) {
                          return 'Enter a valid price.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 18),

                    _buildTextField(
                      label: 'Stock',
                      hint: 'Enter available stock',
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final stock = int.tryParse(value?.trim() ?? '');

                        if (stock == null || stock < 0) {
                          return 'Enter a valid stock.';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 22),

                    _buildStatusSelector(),

                    const SizedBox(height: 30),

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
