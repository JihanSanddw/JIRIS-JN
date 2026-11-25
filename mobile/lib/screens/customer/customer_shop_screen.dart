import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/screens/product_detail/product_detail_screen.dart';
import 'package:mobile/services/cart_service.dart';
import 'package:mobile/services/product_service.dart';

class ShopScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  final int? initialCategoryId;

  const ShopScreen({super.key, this.onNavigate, this.initialCategoryId});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  late Future<Map<String, dynamic>> _productsFuture;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final Set<int> _addingProductIds = {};

  List<Map<String, dynamic>> _availableProducts = [];

  int? _selectedCategoryId;
  int? _selectedCompanyId;

  String? _selectedStyle;
  String _selectedSort = 'Featured';

  double? _minPrice;
  double? _maxPrice;

  int _selectedNav = 1;

  static const List<String> _styles = [
    'Scandinavian',
    'Minimalist',
    'Vintage',
    'Modern',
    'Monochrome',
    'Industrial',
  ];

  static const List<String> _sortOptions = [
    'Featured',
    'Newest',
    'Price: Low to High',
    'Price: High to Low',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    _productsFuture = ProductService.getProducts(
      categoryId: _selectedCategoryId,
      page: 1,
      limit: 50,
      sortBy: 'created_at',
      order: 'desc',
    );

    _productsFuture
        .then((result) {
          if (!mounted) return;

          setState(() {
            _availableProducts = List<Map<String, dynamic>>.from(
              result['products'] ?? [],
            );
          });
        })
        .catchError((error) {});
  }

  Future<void> _applyFilters({String? search}) async {
    setState(() {
      _productsFuture = ProductService.getProducts(
        search: search ?? _searchController.text,
        categoryId: _selectedCategoryId,
        companyId: _selectedCompanyId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        page: 1,
        limit: 100,
        sortBy: _getSortBy(),
        order: _getSortOrder(),
      );
    });

    try {
      final result = await _productsFuture;

      if (!mounted) return;

      setState(() {
        _availableProducts = List<Map<String, dynamic>>.from(
          result['products'] ?? [],
        );
      });
    } catch (_) {}
  }

  String _getSortBy() {
    switch (_selectedSort) {
      case 'Price: Low to High':
      case 'Price: High to Low':
        return 'price';

      case 'Newest':
      case 'Featured':
      default:
        return 'created_at';
    }
  }

  String _getSortOrder() {
    switch (_selectedSort) {
      case 'Price: Low to High':
        return 'asc';

      case 'Price: High to Low':
        return 'desc';

      case 'Newest':
      case 'Featured':
      default:
        return 'desc';
    }
  }

  List<Map<String, dynamic>> _filterByStyle(
    List<Map<String, dynamic>> products,
  ) {
    if (_selectedStyle == null) return products;

    return products.where((product) {
      final content = [
        product['name'],
        product['description'],
        product['category_name'],
        product['company_name'],
      ].join(' ').toLowerCase();

      return content.contains(_selectedStyle!.toLowerCase());
    }).toList();
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

  Future<void> _showChoiceSheet({
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) async {
    final result = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: JirisColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: JirisColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: JirisColors.primary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    ...options.map((option) {
                      final isSelected = selected == option;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          option,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected
                                ? JirisColors.primary
                                : JirisColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check,
                                color: JirisColors.primary,
                              )
                            : null,
                        onTap: () {
                          Navigator.pop(context, option);
                        },
                      );
                    }),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Clear selection',
                        style: TextStyle(
                          color: JirisColors.error,
                          fontSize: 13,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context, '__clear__');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || result == null) return;

    onSelected(result == '__clear__' ? null : result);
  }

  Future<void> _showPriceFilter() async {
    _minPriceController.text = _minPrice?.toStringAsFixed(0) ?? '';

    _maxPriceController.text = _maxPrice?.toStringAsFixed(0) ?? '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: JirisColors.surface,
          title: const Text(
            'Price Range',
            style: TextStyle(color: JirisColors.primary, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minimum price',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Maximum price',
                  prefixText: 'Rp ',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                setState(() {
                  _minPrice = null;
                  _maxPrice = null;
                });
                _applyFilters();
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: JirisColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final min = double.tryParse(_minPriceController.text);

                final max = double.tryParse(_maxPriceController.text);

                if (min != null && max != null && min > max) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Minimum price cannot exceed maximum price.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  _minPrice = min;
                  _maxPrice = max;
                });

                Navigator.pop(dialogContext);
                _applyFilters();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectCategory() async {
    final categories = <int, String>{};

    for (final product in _availableProducts) {
      final id = int.tryParse(product['category_id'].toString());

      final name = product['category_name']?.toString();

      if (id != null && name != null && name.isNotEmpty) {
        categories[id] = name;
      }
    }

    final options = categories.values.toList();

    await _showChoiceSheet(
      title: 'Choose Category',
      options: options,
      selected: _selectedCategoryId == null
          ? null
          : categories[_selectedCategoryId],
      onSelected: (value) {
        setState(() {
          _selectedCategoryId = value == null
              ? null
              : categories.entries
                    .firstWhere((entry) => entry.value == value)
                    .key;
        });

        _applyFilters();
      },
    );
  }

  Future<void> _selectBrand() async {
    final companies = <int, String>{};

    for (final product in _availableProducts) {
      final id = int.tryParse(product['company_id'].toString());

      final name = product['company_name']?.toString();

      if (id != null && name != null && name.isNotEmpty) {
        companies[id] = name;
      }
    }

    final options = companies.values.toList();

    await _showChoiceSheet(
      title: 'Choose Brand',
      options: options,
      selected: _selectedCompanyId == null
          ? null
          : companies[_selectedCompanyId],
      onSelected: (value) {
        setState(() {
          _selectedCompanyId = value == null
              ? null
              : companies.entries
                    .firstWhere((entry) => entry.value == value)
                    .key;
        });

        _applyFilters();
      },
    );
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

  Widget _buildHeader() {
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

              // IconButton(
              //   icon: const Icon(Icons.logout),
              //   onPressed: () async {
              //     await AuthService.logout();

              //     if (!context.mounted) return;

              //     Navigator.pushNamedAndRemoveUntil(
              //       context,
              //       '/welcome',
              //       (route) => false,
              //     );
              //   },
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 28, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find your sense of home.',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 25,
              color: JirisColors.primary,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Furniture from NORD, FORMA & ATELIER.',
            style: TextStyle(fontSize: 13, color: JirisColors.primary),
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
        onSubmitted: (value) {
          _applyFilters(search: value);
        },
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(fontSize: 12),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: IconButton(
            onPressed: () {
              _searchController.clear();
              _applyFilters(search: '');
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

  Widget _buildFilterChip(
    String label,
    VoidCallback onTap, {
    bool selected = false,
  }) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: selected ? Colors.white : JirisColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: JirisColors.primary,
      backgroundColor: JirisColors.surface,
      side: BorderSide(
        color: selected ? JirisColors.primary : JirisColors.border,
      ),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _buildFilterChip(
            'All',
            () {
              setState(() {
                _selectedCategoryId = null;
                _selectedCompanyId = null;
                _selectedStyle = null;
                _minPrice = null;
                _maxPrice = null;
                _searchController.clear();
              });
              _applyFilters(search: '');
            },
            selected:
                _selectedCategoryId == null &&
                _selectedCompanyId == null &&
                _selectedStyle == null &&
                _minPrice == null &&
                _maxPrice == null,
          ),

          const SizedBox(width: 8),

          _buildFilterChip(
            'Category',
            _selectCategory,
            selected: _selectedCategoryId != null,
          ),

          const SizedBox(width: 8),

          _buildFilterChip(
            'Price',
            _showPriceFilter,
            selected: _minPrice != null || _maxPrice != null,
          ),

          const SizedBox(width: 8),

          _buildFilterChip(
            'Brand',
            _selectBrand,
            selected: _selectedCompanyId != null,
          ),

          const SizedBox(width: 8),

          _buildFilterChip(_selectedStyle ?? 'Style', () async {
            await _showChoiceSheet(
              title: 'Choose Interior Style',
              options: _styles,
              selected: _selectedStyle,
              onSelected: (value) {
                setState(() {
                  _selectedStyle = value;
                });
                _applyFilters();
              },
            );
          }, selected: _selectedStyle != null),
        ],
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
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
  }

  Widget _imagePlaceholder() {
    return Container(
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

  Widget _buildSortRow(int productCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$productCount furniture pieces',
            style: const TextStyle(fontSize: 12, color: JirisColors.primary),
          ),
          GestureDetector(
            onTap: () async {
              await _showChoiceSheet(
                title: 'Sort Products',
                options: _sortOptions,
                selected: _selectedSort,
                onSelected: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedSort = value;
                  });

                  _applyFilters();
                },
              );
            },
            child: Row(
              children: [
                Text(
                  'Sort: $_selectedSort',
                  style: const TextStyle(
                    fontSize: 11,
                    color: JirisColors.primary,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 15,
                  color: JirisColors.primary,
                ),
              ],
            ),
          ),
        ],
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
          height: 62,
          child: Row(
            children: List.generate(4, (index) {
              final selected = _selectedNav == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (index == 0) {
                      Navigator.pushReplacementNamed(context, '/customer-home');
                    } else if (index == 1) {
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
              child: RefreshIndicator(
                color: JirisColors.primary,
                onRefresh: () async {
                  await _applyFilters();
                },
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: JirisColors.primary,
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildError(snapshot.error);
                    }

                    final products =
                        (snapshot.data?['products'] as List?)
                            ?.cast<Map<String, dynamic>>() ??
                        <Map<String, dynamic>>[];

                    final filteredProducts = _filterByStyle(products);

                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _buildIntroduction()),
                        SliverToBoxAdapter(child: _buildSearchBar()),
                        SliverToBoxAdapter(child: _buildFilters()),
                        SliverToBoxAdapter(
                          child: _buildSortRow(filteredProducts.length),
                        ),
                        if (filteredProducts.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No furniture found.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: JirisColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
                            sliver: SliverGrid(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return _buildProductCard(
                                  filteredProducts[index],
                                );
                              }, childCount: filteredProducts.length),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 26,
                                    childAspectRatio: 0.62,
                                  ),
                            ),
                          ),
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
                            child: Text(
                              'Furniture from NORD, FORMA & ATELIER.',
                              style: TextStyle(
                                fontSize: 11,
                                color: JirisColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
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
