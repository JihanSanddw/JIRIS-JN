class ApiConfig {
  // static const String baseUrl = 'http://localhost:3663/api';
  static const String baseUrl = 'http://192.168.1.8:3663/api';
  // static const String baseUrl = 'http://10.2.11.228:3663/api';

  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';

  static const String profile = '$baseUrl/users/profile';

  static const String products = '$baseUrl/products';
  static const String categories = '$baseUrl/categories';
  static const String cart = '$baseUrl/cart';
  static const String orders = '$baseUrl/orders';
  static const String checkout = '$orders/checkout';
  static const String myOrders = '$orders/my-orders';
  static const String companies = '$baseUrl/companies';
}
