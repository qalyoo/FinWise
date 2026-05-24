import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen2 extends StatelessWidget {
  const WelcomeScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2340),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Картки
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 40,
                    left: 20,
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Image.asset(
                        'assets/images/Card 15.png',
                        width: 260,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    child: Transform.rotate(
                      angle: 0.1,
                      child: Image.asset(
                        'assets/images/Card 13.png',
                        width: 260,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 120,
                    right: 20,
                    child: Transform.rotate(
                      angle: -0.05,
                      child: Image.asset(
                        'assets/images/Card 16.png',
                        width: 240,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Нижня частина
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '"An investment in\nknowledge pays the\nbest interest."\nBenjamin Franklin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Індикатори
                      Row(
                        children: [
                          Container(
                            width: 16,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey[600],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 24,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),

                      // Кнопка
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2A2F4E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 14,
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Далі',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
