import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/services/product_service.dart';
import 'package:mobile/services/category_service.dart';
import 'package:mobile/services/company_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';

class AdminEditProductScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const AdminEditProductScreen({super.key, required this.product});

  @override
  State<AdminEditProductScreen> createState() => _AdminEditProductScreenState();
}

class _AdminEditProductScreenState extends State<AdminEditProductScreen> {
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
  String? _existingImageUrl;
  String? _errorMessage;

  bool _isLoading = false;
  bool _isSaving = false;

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadDropdownData();
  }

  void _initializeForm() {
    final product = widget.product;

    _nameController.text = product['name']?.toString() ?? '';
    _descriptionController.text = product['description']?.toString() ?? '';

    _priceController.text = product['price']?.toString() ?? '';
    _stockController.text = product['stock']?.toString() ?? '';

    _selectedCategoryId = _toInt(product['category_id']);
    _selectedCompanyId = _toInt(product['company_id']);

    _selectedStatus = product['status']?.toString() ?? 'published';

    _existingImageUrl = product['image_url']?.toString();
  }

  Future<void> _loadDropdownData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
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

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
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

      if (image == null) return;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih kategori dan perusahaan.')),
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());

    if (price == null || stock == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga atau stok tidak valid.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ProductService.updateProduct(
        id: _toInt(widget.product['id']),
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
        const SnackBar(content: Text('Produk berhasil diperbarui.')),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui produk: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12),
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
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
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
          ),
          hint: const Text('Select an option', style: TextStyle(fontSize: 12)),
          items: items.map((item) {
            return DropdownMenuItem<int>(
              value: _toInt(item['id']),
              child: Text(
                item['name']?.toString() ?? '',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) {
            if (value == null) {
              return 'This field is required.';
            }
            return null;
          },
        ),
      ],
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
          onTap: _pickImage,
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
                ? Image.file(_selectedImage!, fit: BoxFit.cover)
                : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty)
                ? Image.network(
                    _existingImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap the image to choose a new one. Leave unchanged to keep the current image.',
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
        ],
      ),
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
            Expanded(child: _statusOption('published', 'Published')),
            const SizedBox(width: 10),
            Expanded(child: _statusOption('draft', 'Draft')),
          ],
        ),
      ],
    );
  }

  Widget _statusOption(String value, String label) {
    final selected = _selectedStatus == value;

    return GestureDetector(
      onTap: () {
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JirisColors.background,
      appBar: AppBar(
        backgroundColor: JirisColors.background,
        foregroundColor: JirisColors.primary,
        elevation: 0,
        title: const Text(
          'Edit Product',
          style: TextStyle(fontFamily: 'Italiana', fontSize: 25),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: JirisColors.primary),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: _loadDropdownData,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 35),
                children: [
                  const Text(
                    'Update your furniture product details.',
                    style: TextStyle(
                      fontSize: 12,
                      color: JirisColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildImagePicker(),
                  const SizedBox(height: 22),

                  _buildTextField(
                    label: 'Product name',
                    controller: _nameController,
                    hint: 'Enter product name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Product name is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  _buildTextField(
                    label: 'Description',
                    controller: _descriptionController,
                    hint: 'Enter product description',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 18),

                  _buildTextField(
                    label: 'Price (Rp)',
                    controller: _priceController,
                    hint: 'Enter product price',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) {
                      final price = double.tryParse(value ?? '');
                      if (price == null || price < 0) {
                        return 'Enter a valid price.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  _buildTextField(
                    label: 'Stock',
                    controller: _stockController,
                    hint: 'Enter product stock',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final stock = int.tryParse(value ?? '');
                      if (stock == null || stock < 0) {
                        return 'Enter a valid stock.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  _buildDropdown(
                    label: 'Category',
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
                    value: _selectedCompanyId,
                    items: _companies,
                    onChanged: (value) {
                      setState(() {
                        _selectedCompanyId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 22),

                  _buildStatusSelector(),
                  const SizedBox(height: 30),

                  SizedBox(
                    height: 50,
                    child: JirisButton(
                      text: 'Save Changes',
                      onPressed: _isSaving ? null : _saveProduct,
                    ),

                    // ElevatedButton(
                    //   onPressed:
                    //       _isSaving ? null : _saveProduct,
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: JirisColors.primary,
                    //     foregroundColor: Colors.white,
                    //     elevation: 0,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius:
                    //           BorderRadius.circular(30),
                    //     ),
                    //   ),
                    //   child: _isSaving
                    //       ? const SizedBox(
                    //           width: 20,
                    //           height: 20,
                    //           child: CircularProgressIndicator(
                    //             strokeWidth: 2,
                    //             color: Colors.white,
                    //           ),
                    //         )
                    //       : const Text(
                    //           'Save Changes',
                    //           style: TextStyle(
                    //             fontSize: 13,
                    //             fontWeight: FontWeight.w600,
                    //           ),
                    //         ),
                    // ),
                  ),
                ],
              ),
            ),
    );
  }
}
