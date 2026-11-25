import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/services/category_service.dart';
import 'package:mobile/services/product_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<Map<String, dynamic>> _dashboardFuture;

  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  void _loadDashboard() {
    _dashboardFuture = _fetchDashboardData();
  }

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    final Map<String, dynamic> productResult = await ProductService.getProducts(
      page: 1,
      limit: 100,
      sortBy: 'created_at',
      order: 'desc',
    );

    final List<Map<String, dynamic>> categories =
        await CategoryService.getCategories();

    final List<Map<String, dynamic>> products = List<Map<String, dynamic>>.from(
      productResult['products'] ?? [],
    );

    final companies = <String>{};

    for (final product in products) {
      final companyId = product['company_id']?.toString();

      if (companyId != null && companyId.isNotEmpty) {
        companies.add(companyId);
      }
    }

    return {
      'products': products.length,
      'categories': categories.length,
      'companies': companies.length,
    };
  }

  // Future<void> _logout() async {
  //   await AuthService.logout();

  //   if (!mounted) return;

  //   Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  // }

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
      padding: EdgeInsets.fromLTRB(24, 32, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your catalog, at a glance.',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 25,
              color: JirisColors.primary,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'One place for your furniture companies.',
            style: TextStyle(fontSize: 13, color: JirisColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String value, required String label}) {
    return Expanded(
      child: Container(
        height: 98,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: JirisColors.lavender,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w600,
                color: JirisColors.primary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: JirisColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatCard(
            value: '${data['products']}',
            label: 'Published products',
          ),
          const SizedBox(width: 12),
          _buildStatCard(value: '${data['categories']}', label: 'Categories'),
        ],
      ),
    );
  }

  Widget _buildAddProductButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
      child: SizedBox(
        width: double.infinity,
        height: 51,
        child: JirisButton(
          text: 'Add a product',
          onPressed: () async {
            await Navigator.pushNamed(context, '/admin-create-product');
          },
        ),

        // ElevatedButton(
        //   onPressed: () => _showComingSoon('Add a product'),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: JirisColors.primary,
        //     foregroundColor: Colors.white,
        //     elevation: 0,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(30),
        //     ),
        //   ),
        //   child: const Row(
        //     children: [
        //       Icon(Icons.add, size: 21),
        //       Spacer(),
        //       Text(
        //         'Add a product',
        //         style: TextStyle(
        //           fontSize: 13,
        //           fontWeight: FontWeight.w600,
        //         ),
        //       ),
        //       Spacer(),
        //       SizedBox(width: 21),
        //     ],
        //   ),
        // ),
      ),
    );
  }

  Widget _buildShortcut({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 19),
      decoration: BoxDecoration(
        color: JirisColors.surface,
        border: Border.all(color: JirisColors.border, width: 0.8),
        borderRadius: BorderRadius.circular(13),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, size: 21, color: JirisColors.secondary),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: JirisColors.primary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: JirisColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: JirisColors.secondary,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatalogShortcuts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catalog shortcuts',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: JirisColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          _buildShortcut(
            icon: Icons.shopping_bag_outlined,
            title: 'Manage products',
            subtitle: 'Companies, prices, images & products',
            onTap: () => Navigator.pushNamed(context, '/admin-products'),
          ),
          _buildShortcut(
            icon: Icons.check,
            title: 'Stock & orders',
            subtitle: 'Order and inventory management',
            onTap: () => Navigator.pushNamed(context, '/admin-products'),
          ),
          _buildShortcut(
            icon: Icons.grid_view_outlined,
            title: 'Manage categories',
            subtitle: 'Furniture categories',
            onTap: () => Navigator.pushNamed(context, '/admin-categories'),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyCard(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JirisColors.lavender,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ready for customers',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: JirisColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${data['products']} furniture pieces · '
            '${data['companies']} companies. '
            'Customer and Admin roles.',
            style: const TextStyle(
              fontSize: 11,
              height: 1.5,
              color: JirisColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewLink() {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/customer-home',
            arguments: {'fromAdmin': true},
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        ),
        child: const Text(
          'Preview customer catalog',
          style: TextStyle(fontSize: 12, color: JirisColors.primary),
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
              final selected = _selectedNav == index;

              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedNav = index;
                    });

                    if (index == 1) {
                      Navigator.pushReplacementNamed(
                        context,
                        '/admin-products',
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
              'Unable to load dashboard',
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
                setState(_loadDashboard);
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
                  setState(_loadDashboard);
                  await _dashboardFuture;
                },
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _dashboardFuture,
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

                    final data = snapshot.data!;

                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      // padding: const EdgeInsets.only(bottom: 20),
                      children: [
                        _buildIntroduction(),
                        _buildStatistics(data),
                        _buildAddProductButton(),
                        _buildCatalogShortcuts(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildReadyCard(data),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildPreviewLink(),
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
