import 'package:flutter/material.dart';
import 'package:mobile/core/theme/jiris_theme.dart';
import 'package:mobile/screens/auth/login_screen.dart';
import 'package:mobile/widgets/buttons/jiris_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JirisColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 5),

              Text(
                'JIRIS',
                style: TextStyle(
                  fontFamily: 'Italiana',
                  fontSize: 68,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -3,
                  color: JirisColors.primary,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Discover furniture. Create a home that\n'
                'feels like you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.2,
                  fontWeight: FontWeight.w400,
                  color: JirisColors.primary,
                ),
              ),

              const Spacer(flex: 6),

              JirisButton(
                text: 'Sign in',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),

              // SizedBox(
              //   width: double.infinity,
              //   height: 45,
              //   child:
              //     ElevatedButton(
              //       onPressed: () {
              //         Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (_) => const LoginScreen(),
              //           ),
              //         );
              //       },
              //       style: ElevatedButton.styleFrom(
              //         backgroundColor: JirisColors.primary,
              //         foregroundColor: Colors.white,
              //         elevation: 0,
              //         shape: const StadiumBorder(),
              //       ),
              //       child: const Text(
              //         'Sign in',
              //         style: TextStyle(
              //           fontSize: 14,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       ),
              //     ),
              // ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
