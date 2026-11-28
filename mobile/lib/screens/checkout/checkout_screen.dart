import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/services/cart_service.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/services/order_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  List<Map<String, dynamic>> _items = [];

  double _subtotal = 0;
  bool _isLoading = true;
  bool _isBusy = false;

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _notesController = TextEditingController();

  final double _deliveryFee = 250000;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCheckoutData() async {
    try {
      final cart = await CartService.getCart();

      Map<String, dynamic> user = {};

      _nameController.text = user['name']?.toString() ?? '';

      try {
        user = await AuthService.getProfile();
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _items = List<Map<String, dynamic>>.from(cart['items'] ?? []);

        _subtotal = double.tryParse(cart['total'].toString()) ?? 0;

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

  double get _orderTotal => _subtotal + _deliveryFee;

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
                onPressed: () => Navigator.pop(context),
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

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: JirisColors.border, width: 0.8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: JirisColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    Widget buildInput({
      required String label,
      required TextEditingController controller,
      required String hint,
      int maxLines = 1,
      TextInputType keyboardType = TextInputType.text,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: JirisColors.primary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(fontSize: 12),
                filled: true,
                fillColor: JirisColors.background,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: JirisColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: JirisColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: JirisColors.primary),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildSectionCard(
      title: 'Delivery address',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildInput(
            label: 'Recipient name',
            controller: _nameController,
            hint: 'Enter recipient name',
          ),
          buildInput(
            label: 'Phone number',
            controller: _phoneController,
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
          ),
          buildInput(
            label: 'Full address',
            controller: _addressController,
            hint: 'Street, house number, city, postal code',
            maxLines: 3,
          ),
          buildInput(
            label: 'Order notes (optional)',
            controller: _notesController,
            hint: 'Additional delivery instructions',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: JirisColors.lavender,
        borderRadius: BorderRadius.circular(9),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _imagePlaceholder();
              },
            )
          : _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return const Center(
      child: Icon(Icons.chair_outlined, size: 28, color: JirisColors.secondary),
    );
  }

  Widget _buildProductList() {
    return Column(
      children: _items.map((item) {
        final name = item['name']?.toString() ?? 'Product';
        final image = item['image_url']?.toString();

        final quantity = int.tryParse(item['quantity'].toString()) ?? 1;

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            children: [
              _buildProductImage(image),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: JirisColors.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Quantity: $quantity',
                      style: const TextStyle(
                        fontSize: 11,
                        color: JirisColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(item['price']),
                      style: const TextStyle(
                        fontSize: 12,
                        color: JirisColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeliveryCard() {
    return _buildSectionCard(
      title: 'Delivery & assembly',
      child: const Text(
        '5–7 days',
        style: TextStyle(fontSize: 12, color: JirisColors.primary),
      ),
    );
  }

  Widget _buildPaymentCard() {
    return _buildSectionCard(
      title: 'Payment method',
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_outlined,
            size: 21,
            color: JirisColors.primary,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'PayPal',
              style: TextStyle(fontSize: 12, color: JirisColors.primary),
            ),
          ),
          Icon(Icons.keyboard_arrow_down, color: JirisColors.secondary),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: JirisColors.primary),
          ),
          Text(
            _formatPrice(amount),
            style: const TextStyle(fontSize: 12, color: JirisColors.primary),
          ),
        ],
      ),
    );
  }

  Future<void> _placeOrder() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your delivery details.')),
      );
      return;
    }

    if (_items.isEmpty || _isBusy) return;

    setState(() => _isBusy = true);

    try {
      await OrderService.checkout(
        recipientName: _nameController.text.trim(),
        recipientPhone: _phoneController.text.trim(),
        shippingAddress: _addressController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Order successful!'),
            content: const Text('Your order has been placed successfully.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('View Account'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(context, '/account', (route) => false);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Widget _buildBottomBar() {
    if (_items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 17, 24, 22),
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
                  'Order total',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: JirisColors.primary,
                  ),
                ),
                Text(
                  _formatPrice(_orderTotal),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: JirisColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: JirisButton(
                text: 'Place Order',
                onPressed: _isBusy ? null : _placeOrder,
              ),

              // ElevatedButton(
              //   onPressed: _isBusy ? null : _placeOrder,
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: JirisColors.primary,
              //     foregroundColor: Colors.white,
              //     elevation: 0,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //   ),
              //   child: _isBusy
              //     ? const SizedBox(
              //         width: 20,
              //         height: 20,
              //         child: CircularProgressIndicator(
              //           color: Colors.white,
              //           strokeWidth: 2,
              //         ),
              //       )
              //     : const Text(
              //         'Place Order',
              //         style: TextStyle(
              //           fontSize: 13,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              // ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Prototype checkout · no real payment',
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
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.shopping_bag_outlined,
                            size: 45,
                            color: JirisColors.secondary,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Your cart is empty.',
                            style: TextStyle(
                              fontFamily: 'Italiana',
                              fontSize: 22,
                              color: JirisColors.primary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Back to cart'),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                      children: [
                        _buildProgress(),
                        const SizedBox(height: 22),
                        const Text(
                          'Checkout',
                          style: TextStyle(
                            fontFamily: 'Italiana',
                            fontSize: 27,
                            color: JirisColors.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildAddressCard(),
                        const SizedBox(height: 16),
                        _buildProductList(),
                        _buildDeliveryCard(),
                        const SizedBox(height: 16),
                        _buildPaymentCard(),
                        const SizedBox(height: 20),
                        _buildPriceRow('Subtotal', _subtotal),
                        _buildPriceRow('Delivery', _deliveryFee),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isLoading ? null : _buildBottomBar(),
    );
  }
}
