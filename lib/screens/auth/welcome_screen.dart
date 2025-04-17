import 'package:flutter/material.dart';
//import 'package:lease_link_app/screens/auth/login_screen.dart';
import 'package:lease_link_app/main.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.house_rounded,
                size: 100,
                color: Colors.purple,
              ),
              const SizedBox(height: 24),
              const Text(
                'Welcome to LeaseLink',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // 👈 Updated for dark mode
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your student-friendly sublease marketplace.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey, // 👈 Looks great on dark background
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  navigatorKey.currentState?.pushNamed('/register'); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
