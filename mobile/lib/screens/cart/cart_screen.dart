import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/services/cart_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _items = [];

  double _total = 0;

  bool _isLoading = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final cart = await CartService.getCart();

      if (!mounted) return;

      setState(() {
        _items = List<Map<String, dynamic>>.from(cart['items'] ?? []);

        _total = double.tryParse(cart['total'].toString()) ?? 0;

        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  String _formatPrice(dynamic value) {
    final number = double.tryParse(value.toString()) ?? 0;
    final formatted = number.round().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < formatted.length; i++) {
      if (i > 0 && (formatted.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(formatted[i]);
    }

    return 'Rp ${buffer.toString()}';
  }

  Future<void> _updateQuantity(Map<String, dynamic> item, int quantity) async {
    if (_isBusy || quantity < 1) return;

    setState(() => _isBusy = true);

    try {
      await CartService.updateCartItem(
        cartItemId: int.parse(item['cart_item_id'].toString()),
        quantity: quantity,
      );

      await _loadCart(showLoading: false);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _removeItem(Map<String, dynamic> item) async {
    if (_isBusy) return;

    setState(() => _isBusy = true);

    try {
      await CartService.deleteCartItem(
        cartItemId: int.parse(item['cart_item_id'].toString()),
      );

      await _loadCart(showLoading: false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product removed from cart.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 17,
                  color: JirisColors.secondary,
                ),
              ),
            ),
            const Text(
              'JIRIS',
              style: TextStyle(
                fontFamily: 'Italiana',
                fontSize: 29,
                color: JirisColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgress() {
    return const Text(
      '01 CART    /    02 CHECKOUT    /    03 PAYMENT',
      style: TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: JirisColors.primary,
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    return Container(
      width: 106,
      height: 106,
      decoration: BoxDecoration(
        color: JirisColors.lavender,
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return _imagePlaceholder();
              },
            )
          : _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(Icons.chair_outlined, size: 35, color: JirisColors.secondary),
    );
  }

  Widget _buildQuantityControl(Map<String, dynamic> item) {
    final quantity = int.tryParse(item['quantity'].toString()) ?? 1;

    return Row(
      children: [
        const Text(
          'Quantity',
          style: TextStyle(fontSize: 12, color: JirisColors.primary),
        ),

        const Spacer(),

        _quantityButton(
          icon: Icons.remove,
          onTap: quantity > 1 && !_isBusy
              ? () => _updateQuantity(item, quantity - 1)
              : null,
        ),

        SizedBox(
          width: 48,
          child: Center(
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: JirisColors.primary,
              ),
            ),
          ),
        ),

        _quantityButton(
          icon: Icons.add,
          onTap: !_isBusy
              ? () {
                  final stock = int.tryParse(item['stock'].toString()) ?? 0;

                  if (quantity >= stock) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Maximum available stock reached.'),
                      ),
                    );
                    return;
                  }

                  _updateQuantity(item, quantity + 1);
                }
              : null,
        ),
      ],
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 43,
        height: 43,
        decoration: BoxDecoration(
          border: Border.all(color: JirisColors.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: JirisColors.primary),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final name = item['name']?.toString() ?? 'Product';
    final description = item['description']?.toString() ?? '';

    final image = item['image_url']?.toString();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: JirisColors.border, width: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildProductImage(image),

              const SizedBox(width: 13),

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

                    if (description.isNotEmpty)
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: JirisColors.textSecondary,
                        ),
                      ),

                    const SizedBox(height: 8),

                    Text(
                      _formatPrice(item['price']),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: JirisColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _buildQuantityControl(item),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _isBusy ? null : () => _removeItem(item),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: JirisColors.primary,
              ),
              child: const Text(
                'Remove item',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: JirisColors.lavender,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Made to belong in your home.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: JirisColors.primary,
            ),
          ),

          SizedBox(height: 9),

          Text(
            'Check the dimensions, finish and delivery access '
            'before placing your order.',
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              color: JirisColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: JirisColors.border, width: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: JirisColors.primary,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Product subtotal',
                style: TextStyle(fontSize: 12, color: JirisColors.primary),
              ),

              Text(
                _formatPrice(_total),
                style: const TextStyle(
                  fontSize: 12,
                  color: JirisColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          const Text(
            'Delivery calculated at checkout.',
            style: TextStyle(fontSize: 10, color: JirisColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: JirisColors.secondary,
            ),

            const SizedBox(height: 16),

            const Text(
              'Your cart is waiting.',
              style: TextStyle(
                fontFamily: 'Italiana',
                fontSize: 23,
                color: JirisColors.primary,
              ),
            ),

            const SizedBox(height: 9),

            const Text(
              'Discover furniture pieces that belong in your home.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: JirisColors.textSecondary),
            ),

            const SizedBox(height: 18),

            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/shop');
              },
              child: const Text(
                'EXPLORE FURNITURE',
                style: TextStyle(color: JirisColors.primary, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (_items.isEmpty || _isLoading) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: JirisColors.border, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: JirisColors.primary,
                  ),
                ),

                Text(
                  _formatPrice(_total),
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: JirisColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: JirisButton(
                text: 'Checkout',
                onPressed: _isBusy
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/checkout');
                      },
              ),

              // ElevatedButton(
              //   onPressed: _isBusy
              //       ? null
              //       : () {
              //           Navigator.pushNamed(
              //             context,
              //             '/checkout',
              //           );
              //         },
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: JirisColors.primary,
              //     foregroundColor: Colors.white,
              //     elevation: 0,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //   ),
              //   child: const Text(
              //     'Checkout',
              //     style: TextStyle(
              //       fontSize: 13,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
            ),

            const SizedBox(height: 12),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Secure checkout · review delivery costs',
                style: TextStyle(fontSize: 9, color: JirisColors.textSecondary),
              ),
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
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: JirisColors.primary,
                      ),
                    )
                  : _items.isEmpty
                  ? _buildEmptyCart()
                  : RefreshIndicator(
                      color: JirisColors.primary,
                      onRefresh: () => _loadCart(),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                        children: [
                          _buildProgress(),

                          const SizedBox(height: 24),

                          const Text(
                            'Your furniture cart',
                            style: TextStyle(
                              fontFamily: 'Italiana',
                              fontSize: 27,
                              color: JirisColors.primary,
                            ),
                          ),

                          const SizedBox(height: 22),

                          const Text(
                            'One step closer to a considered home.',
                            style: TextStyle(
                              fontSize: 12,
                              color: JirisColors.primary,
                            ),
                          ),

                          const SizedBox(height: 20),

                          ..._items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildProductCard(item),
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Update quantity or remove this piece from your cart.',
                            style: TextStyle(
                              fontSize: 11,
                              color: JirisColors.primary,
                            ),
                          ),

                          const SizedBox(height: 20),

                          _buildInformationCard(),

                          const SizedBox(height: 20),

                          _buildOrderSummary(),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomBar(),
    );
  }
}
