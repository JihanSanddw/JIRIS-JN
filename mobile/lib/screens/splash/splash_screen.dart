import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/screens/customer/customer_home_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/screens/auth/welcome_screen.dart';
import 'package:mobile/screens/admin/admin_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;

  bool _isChecking = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    _checkSession();
  }

  Future<void> _checkSession() async {
    Widget destination;

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        destination = const WelcomeScreen();
      } else {
        final user = await AuthService.getProfile();

        final role = user['role'];

        if (role == 'admin') {
          destination = const AdminDashboardScreen();
        } else if (role == 'customer') {
          destination = const CustomerHomeScreen();
        } else {
          await AuthService.logout();
          destination = const WelcomeScreen();
        }
      }
    } catch (error) {
      destination = const WelcomeScreen();

      if (mounted) {
        final message = error.toString();

        if (message.contains('SocketException') ||
            message.contains('ClientException')) {
          destination = const WelcomeScreen();
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;

    setState(() {
      _isChecking = false;
    });

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, secondaryAnimation) => destination,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JirisColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: Text(
                'JIRIS',
                style: TextStyle(
                  fontFamily: 'Italiana',
                  fontSize: 68,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -3,
                  color: JirisColors.primary,
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 170,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9E3ED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: AnimatedBuilder(
                    animation: _progress,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progress.value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: JirisColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
