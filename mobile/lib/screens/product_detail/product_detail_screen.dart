import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/services/cart_service.dart';
import 'package:mobile/services/product_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Map<String, dynamic>> _productFuture;

  final Set<int> _addingProductIds = {};

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  void _loadProduct() {
    _productFuture = ProductService.getProductById(widget.productId);
  }

  String _formatPrice(dynamic value) {
    final number = double.tryParse(value.toString()) ?? 0;
    final digits = number.toStringAsFixed(0);

    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(digits[i]);
    }

    return 'Rp ${buffer.toString()}';
  }

  int _getStock(Map<String, dynamic> product) {
    return int.tryParse(product['stock'].toString()) ?? 0;
  }

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final productId = int.tryParse(product['id'].toString());

    if (productId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID produk tidak valid.')));
      return;
    }

    if (_addingProductIds.contains(productId)) return;

    final stock = _getStock(product);

    if (stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk sedang tidak tersedia.')),
      );
      return;
    }

    if (_quantity > stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah melebihi stok yang tersedia.')),
      );
      return;
    }

    setState(() {
      _addingProductIds.add(productId);
    });

    try {
      await CartService.addCartItem(productId: productId, quantity: _quantity);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product['name']} berhasil ditambahkan ke cart.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menambahkan produk: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _addingProductIds.remove(productId);
        });
      }
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 19,
              color: JirisColors.primary,
            ),
          ),

          const Spacer(),

          const Text(
            'JIRIS',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 29,
              color: JirisColors.primary,
            ),
          ),

          const Spacer(),

          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
            icon: const Icon(
              Icons.shopping_bag_outlined,
              color: JirisColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 350,
      color: JirisColors.lavender,
      child: imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _imagePlaceholder();
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(
                  child: CircularProgressIndicator(color: JirisColors.primary),
                );
              },
            )
          : _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(Icons.chair_outlined, size: 65, color: JirisColors.secondary),
    );
  }

  Widget _buildQuantitySelector(int stock) {
    return Row(
      children: [
        const Text(
          'Quantity',
          style: TextStyle(fontSize: 13, color: JirisColors.primary),
        ),

        const Spacer(),

        IconButton(
          onPressed: _quantity > 1
              ? () {
                  setState(() {
                    _quantity--;
                  });
                }
              : null,
          icon: const Icon(Icons.remove_circle_outline),
          color: JirisColors.primary,
        ),

        Text(
          '$_quantity',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: JirisColors.primary,
          ),
        ),

        IconButton(
          onPressed: _quantity < stock
              ? () {
                  setState(() {
                    _quantity++;
                  });
                }
              : null,
          icon: const Icon(Icons.add_circle_outline),
          color: JirisColors.primary,
        ),
      ],
    );
  }

  Widget _buildProductContent(Map<String, dynamic> product) {
    final name = product['name']?.toString() ?? '-';
    final company = product['company_name']?.toString() ?? '';
    final category = product['category_name']?.toString() ?? '';
    final description = product['description']?.toString() ?? '';
    final imageUrl = product['image_url']?.toString() ?? '';
    final price = product['price'] ?? 0;

    final stock = _getStock(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProductImage(imageUrl),

        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category.isNotEmpty)
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: JirisColors.textSecondary,
                  ),
                ),

              const SizedBox(height: 10),

              Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Italiana',
                  fontSize: 29,
                  color: JirisColors.primary,
                ),
              ),

              if (company.isNotEmpty) ...[
                const SizedBox(height: 7),

                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 13,
                    color: JirisColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: 18),

              Text(
                _formatPrice(price),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: JirisColors.primary,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  const Icon(
                    Icons.inventory_2_outlined,
                    size: 16,
                    color: JirisColors.textSecondary,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    stock > 0 ? 'Available: $stock items' : 'Out of stock',
                    style: TextStyle(
                      fontSize: 12,
                      color: stock > 0
                          ? JirisColors.textSecondary
                          : JirisColors.error,
                    ),
                  ),
                ],
              ),

              if (description.isNotEmpty) ...[
                const SizedBox(height: 28),

                const Divider(color: JirisColors.border),

                const SizedBox(height: 18),

                const Text(
                  'Description',
                  style: TextStyle(
                    fontFamily: 'Italiana',
                    fontSize: 23,
                    color: JirisColors.primary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: JirisColors.textSecondary,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              const Divider(color: JirisColors.border),

              const SizedBox(height: 12),

              _buildQuantitySelector(stock),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 45,
              color: JirisColors.secondary,
            ),

            const SizedBox(height: 14),

            const Text(
              'Unable to load product',
              style: TextStyle(fontSize: 16, color: JirisColors.primary),
            ),

            const SizedBox(height: 8),

            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: JirisColors.textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: () {
                setState(_loadProduct);
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
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
              child: FutureBuilder<Map<String, dynamic>>(
                future: _productFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: JirisColors.primary,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildError(snapshot.error!);
                  }

                  if (!snapshot.hasData) {
                    return _buildError(
                      Exception('Data produk tidak ditemukan.'),
                    );
                  }

                  final product = snapshot.data!;

                  final stock = _getStock(product);

                  final isAddingToCart = _addingProductIds.contains(
                    widget.productId,
                  );

                  return Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: _buildProductContent(product),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                        decoration: const BoxDecoration(
                          color: JirisColors.surface,
                          border: Border(
                            top: BorderSide(
                              color: JirisColors.border,
                              width: 0.8,
                            ),
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: JirisButton(
                              text: 'Add To Cart',
                              onPressed: stock <= 0 || isAddingToCart
                                  ? null
                                  : () => _addToCart(product),
                            ),

                            // ElevatedButton(
                            //   onPressed: stock <= 0 || isAddingToCart
                            //       ? null
                            //       : () => _addToCart(product),
                            //   style: ElevatedButton.styleFrom(
                            //     backgroundColor: JirisColors.primary,
                            //     foregroundColor: Colors.white,
                            //     disabledBackgroundColor: JirisColors.border,
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(30),
                            //     ),
                            //   ),
                            //   child: isAddingToCart
                            //       ? const SizedBox(
                            //           width: 20,
                            //           height: 20,
                            //           child: CircularProgressIndicator(
                            //             strokeWidth: 2,
                            //             color: Colors.white,
                            //           ),
                            //         )
                            //       : const Text(
                            //           'ADD TO CART',
                            //           style: TextStyle(
                            //             fontSize: 12,
                            //             letterSpacing: 1.2,
                            //           ),
                            //         ),
                            // ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
