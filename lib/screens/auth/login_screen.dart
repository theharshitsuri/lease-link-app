import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../main_nav_screen.dart';
import 'email_verification_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Email and password can't be empty");
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      if (user == null) {
        _showSnackBar("Login failed. User not found.");
        return;
      }

      if (user.emailConfirmedAt == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(email: email),
          ),
        );
      } else {
        await _handleProfileNavigation(user.id);
      }
    } on AuthException catch (e) {
      _showSnackBar(e.message);
    } catch (e) {
      _showSnackBar("Something went wrong: $e");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        Provider.google,
        redirectTo: 'io.supabase.leaselink://login-callback',
      );
    } catch (e) {
      _showSnackBar("Google Sign-In failed: $e");
    }
  }

  Future<void> loginWithApple() async {
  try {
    final rawNonce = _generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken != null) {
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: Provider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      final user = response.user;
      if (user != null) {
        // Check if profile already exists
        final existingProfile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        // Save full name if available and profile doesn't already exist
        if (existingProfile == null &&
            (credential.givenName != null || credential.familyName != null)) {
          final fullName =
              "${credential.givenName ?? ''} ${credential.familyName ?? ''}".trim();

          await Supabase.instance.client.from('profiles').insert({
            'id': user.id,
            'name': fullName,
            'profile_image_url': '',
          });
        }

        await _handleProfileNavigation(user.id);
      }
    }
  } catch (e) {
    _showSnackBar("Apple Sign-In failed: $e");
  }
}


  Future<void> _handleProfileNavigation(String userId) async {
    final profile = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (profile == null){
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/setup');
    } else {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _generateNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = List.generate(length, (_) => charset[DateTime.now().millisecondsSinceEpoch % charset.length]);
    return random.join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.house_rounded, size: 100, color: Colors.purple),
              const SizedBox(height: 10),
              const Text("LeaseLink", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Montserrat', color: Colors.white)),
              const SizedBox(height: 30),
              const Text("Welcome back", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 30),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Email"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Password"),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                  child: const Text("Forgot Password?", style: TextStyle(color: Colors.purpleAccent)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: isLoading ? null : loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login", style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: loginWithGoogle,
                style: _socialButtonStyle(),
                child: _socialButtonContent('assets/google.png', "Continue with Google"),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: loginWithApple,
                style: _socialButtonStyle(),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.apple, color: Colors.white, size: 22),
                    SizedBox(width: 12),
                    Text("Continue with Apple", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?", style: TextStyle(color: Colors.white70)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                    child: const Text("Register here"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple),
        ),
      );

  ButtonStyle _socialButtonStyle() => OutlinedButton.styleFrom(
        backgroundColor: Colors.black,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  Widget _socialButtonContent(String asset, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(asset, height: 22, width: 22),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      );
}
