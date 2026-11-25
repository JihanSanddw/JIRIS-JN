import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
// import 'package:mobile/screens/account/settings_screen.dart';
import 'package:mobile/screens/product_detail/product_detail_screen.dart';
import 'package:mobile/services/cart_service.dart';
import 'package:mobile/services/product_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late Future<Map<String, dynamic>> _productsFuture;

  final TextEditingController _searchController = TextEditingController();
  final Set<int> _addingProductIds = {};

  int _selectedNav = 0;
  int _selectedCollection = 0;
  int _selectedFurniture = 0;

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

  void _loadProducts({String? search}) {
    _productsFuture = ProductService.getProducts(
      search: search,
      page: 1,
      limit: 20,
      sortBy: 'created_at',
      order: 'desc',
    );
  }

  void _searchProducts(String value) {
    setState(() {
      _loadProducts(search: value);
    });
  }

  Future<void> _refreshProducts() async {
    setState(() {
      _loadProducts();
    });

    await _productsFuture;
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

  Future<void> _addToCart(Map<String, dynamic> product) async {
    final productId = int.tryParse(product['id'].toString());

    if (productId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID produk tidak valid.')));
      return;
    }

    if (_addingProductIds.contains(productId)) return;

    setState(() {
      _addingProductIds.add(productId);
    });

    try {
      await CartService.addCartItem(productId: productId, quantity: 1);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JirisColors.background,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  final products =
                      (snapshot.data?['products'] as List?)
                          ?.cast<Map<String, dynamic>>() ??
                      <Map<String, dynamic>>[];

                  return RefreshIndicator(
                    color: JirisColors.primary,
                    onRefresh: _refreshProducts,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _buildSearchBar()),

                        SliverToBoxAdapter(child: _buildHeroBanner()),

                        SliverToBoxAdapter(child: _buildIntroduction()),

                        if (snapshot.connectionState == ConnectionState.waiting)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: JirisColors.primary,
                              ),
                            ),
                          )
                        else if (snapshot.hasError)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildError(snapshot.error),
                          )
                        else ...[
                          SliverToBoxAdapter(
                            child: _buildFurnitureSection(
                              title: 'FIND YOUR HOME',
                              firstTab: 'CURATED FURNITURE',
                              secondTab: 'SHOP BY COMPANY',
                              products: products,
                              selectedTab: _selectedCollection,
                              onTabChanged: (value) {
                                setState(() {
                                  _selectedCollection = value;
                                });
                              },
                            ),
                          ),

                          SliverToBoxAdapter(
                            child: _buildFurnitureSection(
                              title: '',
                              firstTab: 'NEW FURNITURE',
                              secondTab: 'TIMELESS DESIGN',
                              products: products,
                              selectedTab: _selectedFurniture,
                              onTabChanged: (value) {
                                setState(() {
                                  _selectedFurniture = value;
                                });
                              },
                            ),
                          ),
                        ],

                        SliverToBoxAdapter(child: _buildDreamRoomSection()),

                        // const SliverToBoxAdapter(
                        //   child: SizedBox(height: 24),
                        // ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    final arguments = ModalRoute.of(context)?.settings.arguments;

    final bool isAdminPreview =
        arguments is Map && arguments['fromAdmin'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 70),

          const Text(
            'JIRIS',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 29,
              fontWeight: FontWeight.w400,
              color: JirisColors.primary,
            ),
          ),

          if (isAdminPreview)
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
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
            )
          else
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/cart');
                  },
                  icon: const Icon(
                    Icons.shopping_bag_outlined,
                    color: JirisColors.primary,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/settings');
                  },
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: JirisColors.primary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 18),
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

  Widget _buildHeroBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          'https://res.cloudinary.com/uofhb05x/image/upload/v1795318803/18ccfbf98ab71b9603072ecd17708315_jofzrh.jpg',
          width: double.infinity,
          height: 460,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 460,
              color: JirisColors.lavender,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 40,
                  color: JirisColors.secondary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIntroduction() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 38),

      child: Column(
        children: [
          const Text(
            'JIRIS',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 42,
              color: JirisColors.primary,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Explore five interior styles and ready-to-use '
            'room layouts, made for considered living.',

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: JirisColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFurnitureSection({
    required String title,
    required String firstTab,
    required String secondTab,
    required List<Map<String, dynamic>> products,
    required int selectedTab,
    required ValueChanged<int> onTabChanged,
  }) {
    List<Map<String, dynamic>> displayedProducts = [];

    if (secondTab == 'SHOP BY COMPANY' && selectedTab == 1) {
      final companies = <String>{};

      for (final product in products) {
        final company = product['company_name']?.toString();

        if (company != null && company.isNotEmpty) {
          companies.add(company);
        }
      }

      displayedProducts = companies.map((company) {
        return {'name': company, 'company_name': company, 'is_company': true};
      }).toList();
    } else if (secondTab == 'TIMELESS DESIGN' && selectedTab == 1) {
      displayedProducts = products.where((product) {
        final category =
            product['category_name']?.toString().toLowerCase() ?? '';

        final description =
            product['description']?.toString().toLowerCase() ?? '';

        final name = product['name']?.toString().toLowerCase() ?? '';

        final content = '$category $description $name';

        return content.contains('vintage') ||
            content.contains('classic') ||
            content.contains('timeless');
      }).toList();
    } else {
      displayedProducts = products;
    }

    final items = displayedProducts.take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),

      child: Column(
        children: [
          if (title.isNotEmpty) ...[
            Text(
              title,

              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
                color: JirisColors.primary,
              ),
            ),

            const SizedBox(height: 16),
          ],

          Row(
            children: [
              Expanded(
                child: _buildTab(
                  firstTab,
                  selectedTab == 0,
                  () => onTabChanged(0),
                ),
              ),

              Expanded(
                child: _buildTab(
                  secondTab,
                  selectedTab == 1,
                  () => onTabChanged(1),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),

              child: Text(
                'No products available yet.',
                style: TextStyle(
                  color: JirisColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),

              itemCount: items.length,

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
                childAspectRatio: 0.68,
              ),

              itemBuilder: (context, index) {
                return _buildProductCard(items[index]);
              },
            ),

          const SizedBox(height: 24),

          TextButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/shop');
            },

            icon: const Icon(Icons.arrow_forward, size: 14),

            label: const Text('SHOP ALL'),

            style: TextButton.styleFrom(
              foregroundColor: JirisColors.primary,

              textStyle: const TextStyle(fontSize: 12, letterSpacing: 0.5),
            ),
          ),

          Container(width: 105, height: 1, color: JirisColors.primary),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,

      child: Column(
        children: [
          Text(
            title,

            textAlign: TextAlign.center,

            style: const TextStyle(fontSize: 10, color: JirisColors.primary),
          ),

          const SizedBox(height: 12),

          AnimatedContainer(
            duration: const Duration(milliseconds: 200),

            height: 4,

            decoration: BoxDecoration(
              color: selected ? JirisColors.primary : JirisColors.lavender,

              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    // final isCompany = product['is_company'] == true;

    final imageUrl = product['image_url']?.toString() ?? '';

    return GestureDetector(
      onTap: () {
        final productId = int.tryParse(product['id'].toString());

        if (productId == null) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(productId: productId),
          ),
        );
      },

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageUrl.isNotEmpty)
                    Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  else
                    _imagePlaceholder(),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap:
                            _addingProductIds.contains(
                              int.tryParse(product['id'].toString()),
                            )
                            ? null
                            : () => _addToCart(product),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child:
                              _addingProductIds.contains(
                                int.tryParse(product['id'].toString()),
                              )
                              ? const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: JirisColors.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 19,
                                  color: JirisColors.primary,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),
          Text(
            product['name']?.toString() ?? '-',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: JirisColors.primary),
          ),
          const SizedBox(height: 3),
          Text(
            product['company_name']?.toString() ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: JirisColors.primary),
          ),
          const SizedBox(height: 9),
          Text(
            _formatPrice(product['price'] ?? 0),
            style: const TextStyle(fontSize: 13, color: JirisColors.primary),
          ),
        ],
      ),
    );

    // return Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,

    //   children: [
    //     Expanded(
    //       child: ClipRRect(
    //         borderRadius: BorderRadius.circular(12),

    //         child: Stack(
    //           fit: StackFit.expand,

    //           children: [
    //             if (!isCompany && imageUrl != null && imageUrl.isNotEmpty)
    //               Image.network(
    //                 imageUrl,
    //                 fit: BoxFit.cover,

    //                 errorBuilder: (context, error, stackTrace) {
    //                   return _imagePlaceholder();
    //                 },
    //               )
    //             else
    //               _imagePlaceholder(),

    //             Positioned(
    //               right: 8,
    //               bottom: 8,

    //               child: CircleAvatar(
    //                 radius: 17,
    //                 backgroundColor: Colors.white,

    //                 child: Icon(
    //                   isCompany
    //                       ? Icons.arrow_forward
    //                       : Icons.shopping_bag_outlined,

    //                   size: 17,
    //                   color: JirisColors.primary,
    //                 ),
    //               ),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),

    //     const SizedBox(height: 10),

    //     Text(
    //       product['name']?.toString() ?? '-',

    //       maxLines: 1,
    //       overflow: TextOverflow.ellipsis,

    //       style: const TextStyle(fontSize: 12, color: JirisColors.primary),
    //     ),

    //     const SizedBox(height: 3),

    //     Text(
    //       product['company_name']?.toString() ?? '',

    //       maxLines: 1,
    //       overflow: TextOverflow.ellipsis,

    //       style: const TextStyle(
    //         fontSize: 10,
    //         color: JirisColors.textSecondary,
    //       ),
    //     ),

    //     const SizedBox(height: 8),

    //     if (!isCompany)
    //       Text(
    //         _formatPrice(product['price'] ?? 0),

    //         style: const TextStyle(fontSize: 12, color: JirisColors.primary),
    //       ),
    //   ],
    // );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      color: JirisColors.lavender,

      child: const Center(
        child: Icon(
          Icons.chair_outlined,
          size: 36,
          color: JirisColors.secondary,
        ),
      ),
    );
  }

  Widget _buildDreamRoomSection() {
    return Container(
      width: double.infinity,
      color: JirisColors.lavender,

      padding: const EdgeInsets.fromLTRB(12, 30, 12, 28),

      child: Column(
        children: [
          const Text(
            'DREAM ROOM · LAYOUT TEMPLATES',

            textAlign: TextAlign.center,

            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.5,
              color: JirisColors.primary,
            ),
          ),

          const SizedBox(height: 22),

          _roomTemplate('SCANDINAVIAN · 4 × 5 m', height: 250),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _roomTemplate('MINIMALIST · 3 × 4 m', height: 145),
              ),

              const SizedBox(width: 10),

              Expanded(child: _roomTemplate('VINTAGE · 4 × 4 m', height: 145)),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: _roomTemplate('INDUSTRIAL · 5 × 5 m', height: 145),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _roomTemplate('MONOCHROME · 4 × 5 m', height: 145),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _roomTemplate(String label, {required double height}) {
    return Container(
      height: height,
      width: double.infinity,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),

        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [Color(0xFFE1D8CF), Color(0xFFB6A594)],
        ),
      ),

      alignment: Alignment.bottomLeft,

      padding: const EdgeInsets.all(10),

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),

        child: Text(
          label,

          style: const TextStyle(
            fontSize: 8,
            letterSpacing: 0.5,
            color: JirisColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: JirisColors.secondary,
            ),

            const SizedBox(height: 12),

            const Text(
              'Unable to load furniture',

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

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                setState(() {
                  _loadProducts();
                });
              },

              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation() {
    const icons = [
      Icons.home_outlined,
      Icons.shopping_bag_outlined,
      Icons.grid_view_outlined,
      Icons.person_outline,
    ];

    const labels = ['Home', 'Shop', 'Categories', 'Account'];

    return Container(
      decoration: const BoxDecoration(
        color: JirisColors.surface,

        border: Border(top: BorderSide(color: JirisColors.border, width: 0.8)),
      ),

      child: SafeArea(
        top: false,

        child: SizedBox(
          height: 58,

          child: Row(
            children: List.generate(4, (index) {
              final selected = _selectedNav == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (index == 0) {
                    } else if (index == 1) {
                      Navigator.pushReplacementNamed(context, '/shop');
                    } else if (index == 2) {
                      Navigator.pushReplacementNamed(context, '/categories');
                    } else if (index == 3) {
                      Navigator.pushReplacementNamed(context, '/account');
                    }
                    // else {
                    //   ScaffoldMessenger.of(context).showSnackBar(
                    //     SnackBar(
                    //       content: Text(
                    //         '${labels[index]} page belum tersedia.',
                    //       ),
                    //     ),
                    //   );
                    // }
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
}
