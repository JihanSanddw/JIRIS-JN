import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/screens/account/edit_profile_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/order_service.dart';
import 'package:mobile/widgets/profile/profile_header_section.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<List<Map<String, dynamic>>> _ordersFuture;
  late Future<List<Map<String, dynamic>>> _historyItemsFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadOrders();
  }

  void _loadProfile() {
    _profileFuture = AuthService.getProfile();
  }

  void _loadOrders() {
    _ordersFuture = OrderService.getMyOrders();
    _historyItemsFuture = _loadAllPurchasedItems();
  }

  Future<List<Map<String, dynamic>>> _loadAllPurchasedItems() async {
    final orders = await _ordersFuture;

    final List<Map<String, dynamic>> allItems = [];

    for (final order in orders) {
      final orderId = order['id'];

      final detail = await OrderService.getOrderDetail(orderId);

      final items = List<Map<String, dynamic>>.from(detail['items'] ?? []);

      for (final item in items) {
        allItems.add({
          ...item,
          'order_id': orderId,
          'order_date': order['created_at'],
          'order_status': order['status'],
        });
      }
    }

    return allItems;
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _loadProfile();
      _loadOrders();
    });

    try {
      await Future.wait([_profileFuture, _ordersFuture, _historyItemsFuture]);
    } catch (_) {}
  }

  Widget _buildHeader() {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      color: JirisColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 65),

          const Text(
            'JIRIS',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 29,
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
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile(Map<String, dynamic> user) async {
    final updatedUser = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
    );

    if (!mounted) return;

    if (updatedUser != null) {
      setState(() {
        _loadProfile();
      });
    }
  }

  // Widget _buildDreamRoomSection() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         const Text(
  //           'Your Dream Room',
  //           style: TextStyle(
  //             fontFamily: 'Italiana',
  //             fontSize: 27,
  //             color: JirisColors.primary,
  //           ),
  //         ),

  //         const SizedBox(height: 24),

  //         const Text(
  //           'Furniture saved for your next chapter.',
  //           style: TextStyle(
  //             fontSize: 12,
  //             color: JirisColors.primary,
  //           ),
  //         ),

  //         const SizedBox(height: 24),

  //         // WISHLIST EMPTY STATE
  //         Container(
  //           width: double.infinity,
  //           padding: const EdgeInsets.symmetric(
  //             vertical: 35,
  //             horizontal: 20,
  //           ),
  //           decoration: BoxDecoration(
  //             color: JirisColors.lavender,
  //             borderRadius: BorderRadius.circular(14),
  //           ),
  //           child: Column(
  //             children: [
  //               const Icon(
  //                 Icons.bookmark_border,
  //                 size: 38,
  //                 color: JirisColors.secondary,
  //               ),

  //               const SizedBox(height: 12),

  //               const Text(
  //                 'Your collection starts here',
  //                 style: TextStyle(
  //                   fontFamily: 'Italiana',
  //                   fontSize: 20,
  //                   color: JirisColors.primary,
  //                 ),
  //               ),

  //               const SizedBox(height: 8),

  //               const Text(
  //                 'Save your favorite furniture and create '
  //                 'your dream room collection.',
  //                 textAlign: TextAlign.center,
  //                 style: TextStyle(
  //                   fontSize: 11,
  //                   height: 1.5,
  //                   color: JirisColors.textSecondary,
  //                 ),
  //               ),

  //               const SizedBox(height: 16),

  //               TextButton(
  //                 onPressed: () {
  //                   Navigator.pushReplacementNamed(
  //                     context,
  //                     '/shop',
  //                   );
  //                 },
  //                 child: const Text(
  //                   'EXPLORE FURNITURE',
  //                   style: TextStyle(
  //                     fontSize: 11,
  //                     letterSpacing: 0.8,
  //                     color: JirisColors.primary,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),

  //         const SizedBox(height: 35),

  //         const Text(
  //           'Furniture saved for your next chapter.',
  //           style: TextStyle(
  //             fontSize: 11,
  //             color: JirisColors.textSecondary,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildHistoryCollections() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'History Collections',
            style: TextStyle(
              fontFamily: 'Italiana',
              fontSize: 27,
              color: JirisColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Every piece you have chosen for your home.',
            style: TextStyle(fontSize: 12, color: JirisColors.primary),
          ),

          const SizedBox(height: 24),

          FutureBuilder<List<Map<String, dynamic>>>(
            future: _historyItemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(
                      color: JirisColors.primary,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off_outlined,
                        size: 35,
                        color: JirisColors.secondary,
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Unable to load purchase history.',
                        style: TextStyle(fontSize: 12),
                      ),

                      TextButton(
                        onPressed: () {
                          setState(_loadOrders);
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              final items = snapshot.data ?? [];

              if (items.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 35,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: JirisColors.lavender,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 38,
                        color: JirisColors.secondary,
                      ),

                      SizedBox(height: 12),

                      Text(
                        'No collections yet',
                        style: TextStyle(
                          fontFamily: 'Italiana',
                          fontSize: 20,
                          color: JirisColors.primary,
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Your purchased furniture will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: JirisColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 22,
                  childAspectRatio: 0.58,
                ),
                itemBuilder: (context, index) {
                  return _buildPurchasedProductCard(items[index]);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasedProductCard(Map<String, dynamic> item) {
    final imageUrl = item['product_image_url']?.toString() ?? '';

    final productName = item['product_name']?.toString() ?? 'Furniture';

    final quantity = int.tryParse(item['quantity'].toString()) ?? 0;

    final subtotal = item['subtotal'] ?? 0;

    final orderId = item['order_id'];

    final date = DateTime.tryParse(item['order_date']?.toString() ?? '');

    final formattedDate = date == null
        ? '-'
        : '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/'
              '${date.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: JirisColors.lavender,
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.chair_outlined,
                          size: 35,
                          color: JirisColors.secondary,
                        ),
                      );
                    },
                  )
                : const Center(
                    child: Icon(
                      Icons.chair_outlined,
                      size: 35,
                      color: JirisColors.secondary,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 10),

        Text(
          productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: JirisColors.primary,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Quantity: $quantity',
          style: const TextStyle(fontSize: 11, color: JirisColors.primary),
        ),

        const SizedBox(height: 8),

        Text(
          _formatPrice(subtotal),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: JirisColors.primary,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          'Order #$orderId · $formattedDate',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 9, color: JirisColors.textSecondary),
        ),
      ],
    );
  }

  String _formatPrice(dynamic value) {
    final number = double.tryParse(value.toString())?.round() ?? 0;

    final formatted = number.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(formatted[i]);
    }

    return 'Rp ${buffer.toString()}';
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 42,
              color: JirisColors.secondary,
            ),

            const SizedBox(height: 14),

            const Text(
              'Unable to load profile',
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
                setState(_loadProfile);
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
          height: 62,
          child: Row(
            children: List.generate(4, (index) {
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (index == 0) {
                      Navigator.pushReplacementNamed(context, '/customer-home');
                    } else if (index == 1) {
                      Navigator.pushReplacementNamed(context, '/shop');
                    } else if (index == 2) {
                      Navigator.pushReplacementNamed(context, '/categories');
                    } else if (index == 3) {
                      Navigator.pushReplacementNamed(context, '/account');
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: 20,
                        color: index == 3
                            ? JirisColors.primary
                            : JirisColors.textSecondary,
                      ),

                      const SizedBox(height: 4),

                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 9,
                          color: index == 3
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
              child: FutureBuilder<Map<String, dynamic>>(
                future: _profileFuture,
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
                    return _buildError(Exception('Profile data is empty.'));
                  }

                  final user = snapshot.data!;

                  return RefreshIndicator(
                    color: JirisColors.primary,
                    onRefresh: _refreshProfile,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      children: [
                        ProfileHeaderSection(
                          user: user,
                          showEditButton: true,
                          onEdit: () {
                            _openEditProfile(user);
                          },
                        ),

                        // _buildDreamRoomSection(),
                        _buildHistoryCollections(),
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
}
