import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/services/category_service.dart';
import 'package:mobile/services/product_service.dart';

class CategoriesScreen extends StatefulWidget {
  final ValueChanged<int>? onNavigate;
  final ValueChanged<int>? onCategorySelected;

  const CategoriesScreen({super.key, this.onNavigate, this.onCategorySelected});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<Map<String, dynamic>> _categoriesFuture;

  int _selectedNav = 2;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categoriesFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final results = await Future.wait([
      CategoryService.getCategories(),
      ProductService.getProducts(
        page: 1,
        limit: 50,
        sortBy: 'created_at',
        order: 'desc',
      ),
    ]);

    return {
      'categories': results[0] as List<Map<String, dynamic>>,
      'products':
          (results[1] as Map<String, dynamic>)['products']
              as List<Map<String, dynamic>>,
    };
  }

  String? _getCategoryImage(
    int categoryId,
    List<Map<String, dynamic>> products,
  ) {
    for (final product in products) {
      final productCategoryId = int.tryParse(product['category_id'].toString());

      final imageUrl = product['image_url']?.toString();

      if (productCategoryId == categoryId &&
          imageUrl != null &&
          imageUrl.isNotEmpty) {
        return imageUrl;
      }
    }

    return null;
  }

  void _openCategory(int categoryId) {
    Navigator.pushNamed(context, '/shop', arguments: categoryId);
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
            'Furniture by category',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 25,
              color: JirisColors.primary,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Considered furniture for every space.',
            style: TextStyle(fontSize: 13, color: JirisColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryImage(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 94,
        height: 94,
        child: imageUrl == null
            ? Container(
                color: JirisColors.lavender,
                child: const Icon(
                  Icons.chair_outlined,
                  size: 36,
                  color: JirisColors.secondary,
                ),
              )
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: JirisColors.lavender,
                    child: const Icon(
                      Icons.chair_outlined,
                      size: 36,
                      color: JirisColors.secondary,
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildCategoryCard(
    Map<String, dynamic> category,
    List<Map<String, dynamic>> products,
  ) {
    final id = int.tryParse(category['id'].toString()) ?? 0;

    final name = category['name']?.toString() ?? 'Category';

    final imageUrl = _getCategoryImage(id, products);

    return GestureDetector(
      onTap: () => _openCategory(id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: JirisColors.lavender,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _buildCategoryImage(imageUrl),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: JirisColors.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Crafted for everyday living',
                    style: TextStyle(
                      fontSize: 12,
                      color: JirisColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Row(
                    children: [
                      Text(
                        'Shop collection',
                        style: TextStyle(
                          fontSize: 11,
                          color: JirisColors.primary,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 12,
                        color: JirisColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
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
                      Navigator.pushReplacementNamed(context, '/shop');
                    } else if (index == 2) {
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

  Widget _buildError(Object error) {
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
              'Unable to load categories',
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
                setState(_loadCategories);
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
                  setState(_loadCategories);
                  await _categoriesFuture;
                },
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _categoriesFuture,
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

                    final categories =
                        snapshot.data?['categories']
                            as List<Map<String, dynamic>>? ??
                        [];

                    final products =
                        snapshot.data?['products']
                            as List<Map<String, dynamic>>? ??
                        [];

                    return CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // Introduction
                        SliverToBoxAdapter(child: _buildIntroduction()),

                        // Categories
                        if (categories.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No categories available yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: JirisColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return _buildCategoryCard(
                                  categories[index],
                                  products,
                                );
                              }, childCount: categories.length),
                            ),
                          ),

                        // Footer
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 30),
                            child: Text(
                              'Considered furniture for every space.',
                              style: TextStyle(
                                fontSize: 12,
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
