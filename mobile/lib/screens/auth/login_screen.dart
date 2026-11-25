import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/screens/admin/admin_dashboard_screen.dart';
import 'package:mobile/screens/auth/register_screen.dart';
import 'package:mobile/screens/customer/customer_home_screen.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';
import 'package:mobile/widgets/inputs/jiris_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      final user = result['user'];
      final role = user['role'];

      late Widget destination;

      if (role == 'admin') {
        destination = const AdminDashboardScreen();
      } else if (role == 'customer') {
        destination = const CustomerHomeScreen();
      } else {
        await AuthService.logout();

        throw Exception('Role pengguna tidak dikenali.');
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => destination),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: JirisColors.error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showHelp() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Contact JIRIS support.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JirisColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 38),

                        Center(
                          child: Text(
                            'JIRIS',
                            style: TextStyle(
                              fontFamily: 'Italiana',
                              fontSize: 38,
                              letterSpacing: -1.5,
                              color: JirisColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        Center(
                          child: Text(
                            'Welcome back',
                            style: TextStyle(
                              fontFamily: 'Italiana',
                              fontSize: 30,
                              // fontWeight: FontWeight.w400,
                              color: JirisColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Center(
                          child: Text(
                            'Your next favorite space is waiting.',
                            style: TextStyle(
                              fontSize: 14,
                              color: JirisColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        JirisTextField(
                          label: 'Email address',
                          hint: 'you@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required.';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+$',
                            ).hasMatch(value.trim())) {
                              return 'Invalid email address.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        JirisTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: TextButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            child: Text(
                              _obscurePassword ? 'Show' : 'Hide',
                              style: const TextStyle(
                                color: JirisColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required.';
                            }
                            return null;
                          },
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              foregroundColor: JirisColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),

                        JirisButton(
                          text: 'Sign In',
                          onPressed: _login,
                          isLoading: _isLoading,
                        ),

                        const SizedBox(height: 22),

                        const Center(
                          child: Text(
                            'or',
                            style: TextStyle(
                              fontSize: 12,
                              color: JirisColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: JirisColors.primary,
                              side: const BorderSide(color: Color(0xFFE9E3ED)),
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 22),

                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const Text(
                                'New to JIRIS?  ',
                                style: TextStyle(fontSize: 12),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Create an account',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: JirisColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Center(
                          child: Text(
                            'By signing in, you agree to our Terms of Service and Privacy Policy.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              height: 1.5,
                              color: JirisColors.textSecondary,
                            ),
                          ),
                        ),

                        const Spacer(),

                        const SizedBox(height: 65),

                        Center(
                          child: GestureDetector(
                            onTap: _showHelp,
                            child: const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Need help?  Contact JIRIS',
                                style: TextStyle(
                                  fontSize: 11,
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
              ),
            );
          },
        ),
      ),
    );
  }
}
