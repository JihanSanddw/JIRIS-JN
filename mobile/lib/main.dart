import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/screens/account/account_screen.dart';
import 'package:mobile/screens/account/settings_screen.dart';
import 'package:mobile/screens/admin/admin_account_screen.dart';
import 'package:mobile/screens/admin/admin_categories_screen.dart';
import 'package:mobile/screens/admin/admin_create_category_screen.dart';
import 'package:mobile/screens/admin/admin_create_product_screen.dart';
import 'package:mobile/screens/admin/admin_dashboard_screen.dart';
import 'package:mobile/screens/admin/admin_products_screen.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/screens/auth/register_screen.dart';
import 'package:mobile/screens/auth/welcome_screen.dart';
import 'package:mobile/screens/cart/cart_screen.dart';
import 'package:mobile/screens/checkout/checkout_screen.dart';
import 'package:mobile/screens/customer/customer_categories_screen.dart';
import 'package:mobile/screens/splash/splash_screen.dart';
import 'package:mobile/screens/customer/customer_home_screen.dart';
import 'package:mobile/screens/customer/customer_shop_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JirisApp());
}

class JirisApp extends StatelessWidget {
  const JirisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JIRIS',
      theme: JirisTheme.light,
      home: const SplashScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/customer-home': (context) => const CustomerHomeScreen(),
        '/shop': (context) {
          final categoryId = ModalRoute.of(context)?.settings.arguments;

          return ShopScreen(
            initialCategoryId: categoryId is int ? categoryId : null,
          );
        },
        '/categories': (context) => const CategoriesScreen(),
        '/account': (context) => const AccountScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/admin-dashboard': (context) => const AdminDashboardScreen(),
        '/admin-products': (context) => const AdminProductsScreen(),
        '/admin-create-product': (context) => const AdminCreateProductScreen(),
        '/admin-categories': (context) => const AdminCategoriesScreen(),
        '/admin-create-category': (context) => const AdminCreateCategoryScreen(),
        '/admin-account': (context) => const AdminAccountScreen(),
      },
    );
  }
}
