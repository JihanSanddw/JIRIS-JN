import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';
import 'package:mobile/widgets/inputs/jiris_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Privacy Policy.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Form valid. API integration will follow.'),
      ),
    );
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
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
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
                            'A beautiful home starts here',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Italiana',
                              fontSize: 25,
                              fontWeight: FontWeight.w400,
                              color: JirisColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        const Center(
                          child: Text(
                            'Save furniture and curate your dream room.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: JirisColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 26),

                        JirisTextField(
                          label: 'Full name',
                          hint: 'Your full name',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Full name is required.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

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
                          hint: 'Create a password',
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
                                fontSize: 12,
                                color: JirisColors.primary,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.length < 8) {
                              return 'Password must be at least 8 characters.';
                            }
                            if (!RegExp(r'\d').hasMatch(value)) {
                              return 'Include at least one number.';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Use at least 8 characters, including a number.',
                          style: TextStyle(
                            fontSize: 10,
                            color: JirisColors.textSecondary,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _agreeToTerms,
                                activeColor: JirisColors.primary,
                                side: const BorderSide(
                                  color: Color(0xFFE9E3ED),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToTerms = value ?? false;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'I agree to the Terms of Service and Privacy Policy.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: JirisColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        JirisButton(
                          text: 'Create account',
                          onPressed: _register,
                        ),

                        const SizedBox(height: 22),

                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?  ',
                                style: TextStyle(fontSize: 12),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const LoginScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign in',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: JirisColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        const SizedBox(height: 65),

                        const Center(
                          child: Padding(
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
