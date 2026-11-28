import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/screens/admin/admin_edit_category_screen.dart';
import 'package:mobile/services/category_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';

class AdminCategoriesScreen extends StatefulWidget {
  const AdminCategoriesScreen({super.key});

  @override
  State<AdminCategoriesScreen> createState() => _AdminCategoriesScreenState();
}

class _AdminCategoriesScreenState extends State<AdminCategoriesScreen> {
  late Future<List<Map<String, dynamic>>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  void _loadCategories() {
    _categoriesFuture = CategoryService.getCategories();
  }

  Future<void> _refreshCategories() async {
    setState(_loadCategories);
    await _categoriesFuture;
  }

  Future<void> _editCategory(Map<String, dynamic> category) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminEditCategoryScreen(category: category),
      ),
    );

    if (result == true && mounted) {
      await _refreshCategories();
    }
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    final categoryId = int.tryParse(category['id'].toString());

    if (categoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID kategori tidak valid.')));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Category?'),
          content: Text(
            'Are you sure you want to delete '
            '"${category['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await CategoryService.deleteCategory(categoryId);

      if (!mounted) return;

      setState(_loadCategories);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category successfully deleted.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
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
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 28, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Categories',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 29,
              color: JirisColors.primary,
            ),
          ),
          SizedBox(height: 9),
          Text(
            'Organize your furniture collection.',
            style: TextStyle(fontSize: 12, color: JirisColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: JirisButton(
          text: 'Add Category',
          onPressed: () async {
            final result = await Navigator.pushNamed(
              context,
              '/admin-create-category',
            );

            if (result == true) {
              _refreshCategories();
            }
          },
        ),

        // ElevatedButton(
        //   onPressed: () async {
        //     final result = await Navigator.pushNamed(
        //       context,
        //       '/admin-create-category',
        //     );

        //     if (result == true && mounted) {
        //       await _refreshCategories();
        //     }
        //   },
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: JirisColors.primary,
        //     foregroundColor: Colors.white,
        //     elevation: 0,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(30),
        //     ),
        //   ),
        //   child: const Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: [
        //       Icon(Icons.add, size: 19),
        //       SizedBox(width: 8),
        //       Text(
        //         'Add Category',
        //         style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category) {
    final String name = category['name']?.toString() ?? 'Untitled';
    final String description = category['description']?.toString() ?? '';

    final String? imageUrl = category['image_url']?.toString();

    final int totalProducts =
        int.tryParse(category['total_products']?.toString() ?? '0') ?? 0;

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
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildImagePlaceholder();
                      },
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;

                        return Container(
                          color: JirisColors.lavender,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: JirisColors.primary,
                            ),
                          ),
                        );
                      },
                    )
                  : _buildImagePlaceholder(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: JirisColors.primary,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      height: 1.4,
                      color: JirisColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '$totalProducts products',
                  style: const TextStyle(
                    fontSize: 10,
                    color: JirisColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: JirisColors.secondary),
            onSelected: (value) {
              if (value == 'edit') {
                _editCategory(category);
              } else if (value == 'delete') {
                _deleteCategory(category);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: JirisColors.lavender,
      child: const Center(
        child: Icon(
          Icons.chair_outlined,
          size: 30,
          color: JirisColors.secondary,
        ),
      ),
    );
  }

  Widget _buildCategoryList(List<Map<String, dynamic>> categories) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 70),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.grid_view_outlined,
                size: 45,
                color: JirisColors.secondary,
              ),
              SizedBox(height: 12),
              Text(
                'No categories yet.',
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
      children: categories
          .map((category) => _buildCategoryCard(category))
          .toList(),
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
              final selected = index == 2;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (index == 0) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin-dashboard',
                      );
                    } else if (index == 1) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin-products',
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
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: RefreshIndicator(
                color: JirisColors.primary,
                onRefresh: _refreshCategories,
                child: FutureBuilder<List<Map<String, dynamic>>>(
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

                    final categories = snapshot.data ?? [];

                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      // padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        _buildIntroduction(),
                        _buildAddButton(),
                        const SizedBox(height: 26),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              const Text(
                                'All Categories',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: JirisColors.primary,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${categories.length} categories',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: JirisColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildCategoryList(categories),
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
