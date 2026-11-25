import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/screens/admin/admin_edit_product_screen.dart';
import 'package:mobile/services/product_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _selectedStatus = 'all';
  late Future<List<Map<String, dynamic>>> _productsFuture;

  int _selectedNav = 1;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    _productsFuture = _fetchProducts();
  }

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    final result = await ProductService.getAdminProducts(
      search: _searchController.text.trim(),
      status: _selectedStatus,
      page: 1,
      limit: 100,
      sortBy: 'created_at',
      order: 'desc',
    );

    return List<Map<String, dynamic>>.from(result['products'] ?? []);
  }

  void _refreshProducts() {
    setState(_loadProducts);
  }

  void _changeStatus(String status) {
    setState(() {
      _selectedStatus = status;
      _loadProducts();
    });
  }

  String _formatPrice(dynamic price) {
    final number = double.tryParse(price.toString()) ?? 0;
    final value = number.toInt().toString();
    final formatted = value.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => '.',
    );

    return 'Rp $formatted';
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
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 25, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Products',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 30,
              color: JirisColors.primary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Manage your furniture catalog and product details.',
            style: TextStyle(fontSize: 12, color: JirisColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _refreshProducts(),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(fontSize: 12),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: IconButton(
            onPressed: () {
              _searchController.clear();
              _refreshProducts();
            },
            icon: const Icon(Icons.close, size: 18),
          ),
          filled: true,
          fillColor: JirisColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: JirisColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: JirisColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: JirisColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusFilters() {
    const filters = {'all': 'All', 'published': 'Published', 'draft': 'Draft'};

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
      child: Row(
        children: filters.entries.map((entry) {
          final selected = _selectedStatus == entry.key;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Center(
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 11,
                      color: selected ? Colors.white : JirisColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                selected: selected,
                onSelected: (_) => _changeStatus(entry.key),
                selectedColor: JirisColors.primary,
                backgroundColor: JirisColors.surface,
                side: BorderSide(
                  color: selected ? JirisColors.primary : JirisColors.border,
                ),
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final imageUrl = product['image_url']?.toString() ?? '';
    final name = product['name']?.toString() ?? 'Unnamed product';
    final price = _formatPrice(product['price'] ?? 0);
    final stock = product['stock']?.toString() ?? '0';
    final status = product['status']?.toString() ?? 'published';

    final isPublished = status == 'published';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: JirisColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: JirisColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              width: 88,
              height: 88,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imagePlaceholder(),
                    )
                  : _imagePlaceholder(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: JirisColors.primary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: JirisColors.secondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Stock: $stock',
                  style: const TextStyle(
                    fontSize: 10,
                    color: JirisColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPublished
                        ? JirisColors.lavender
                        : const Color(0xFFF3E8D8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPublished ? 'Published' : 'Draft',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isPublished
                          ? JirisColors.primary
                          : const Color(0xFF926B37),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AdminEditProductScreen(product: product),
                ),
              );

              if (result == true) {
                _refreshProducts();
              }
            },
            icon: const Icon(
              Icons.edit_outlined,
              size: 19,
              color: JirisColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: JirisColors.lavender,
      child: const Icon(
        Icons.chair_outlined,
        size: 34,
        color: JirisColors.secondary,
      ),
    );
  }

  Widget _buildProductList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: JirisColors.primary),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Icon(
                    Icons.cloud_off_outlined,
                    size: 40,
                    color: JirisColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unable to load products.',
                    style: TextStyle(
                      color: JirisColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 10),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _refreshProducts,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Column(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 42,
                    color: JirisColors.secondary,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No products found.',
                    style: TextStyle(
                      fontSize: 13,
                      color: JirisColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: products
              .map((product) => _buildProductCard(product))
              .toList(),
        );
      },
    );
  }

  Widget _buildAddButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: JirisButton(
        text: 'Add Product',
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/admin-create-product',
          );

          if (result == true) {
            _refreshProducts();
          }
        },
      ),

      // ElevatedButton.icon(
      //   onPressed: () async {
      //     final result = await Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const AdminCreateProductScreen(),
      //       ),
      //     );

      //     if (result == true) {
      //       _refreshProducts();
      //     }
      //   },
      //   icon: const Icon(Icons.add, size: 20),
      //   label: const Text(
      //     'Add a product',
      //     style: TextStyle(
      //       fontSize: 13,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   style: ElevatedButton.styleFrom(
      //     backgroundColor: JirisColors.primary,
      //     foregroundColor: Colors.white,
      //     elevation: 0,
      //     shape: RoundedRectangleBorder(
      //       borderRadius: BorderRadius.circular(30),
      //     ),
      //   ),
      // ),
    );
  }

  Widget _buildBottomNavigation() {
    const icons = [
      Icons.home_outlined,
      Icons.shopping_bag_outlined,
      Icons.grid_view_outlined,
      Icons.person_outline,
    ];

    const labels = ['Home', 'Products', 'Categories', 'Account'];

    return Container(
      decoration: const BoxDecoration(
        color: JirisColors.surface,
        border: Border(top: BorderSide(color: JirisColors.border, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: List.generate(4, (index) {
              final selected = _selectedNav == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedNav = index;
                    });

                    if (index == 0) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin-dashboard',
                      );
                    } else if (index == 2) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin-categories',
                      );
                    } else if (index == 3) {
                      Navigator.pushReplacementNamed(context, '/admin-account');
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: 20,
                        color: selected
                            ? JirisColors.primary
                            : JirisColors.textSecondary,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 9,
                          color: selected
                              ? JirisColors.primary
                              : JirisColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
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
              child: RefreshIndicator(
                color: JirisColors.primary,
                onRefresh: () async {
                  _refreshProducts();
                  await _productsFuture;
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  // padding: const EdgeInsets.only(bottom: 30),
                  children: [
                    _buildIntroduction(),
                    _buildSearchBar(),
                    _buildStatusFilters(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildAddButton(),
                    ),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(24, 26, 24, 14),
                      child: Text(
                        'Product catalog',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: JirisColors.primary,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildProductList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }
}
