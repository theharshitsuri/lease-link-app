// You'll typically wire the profile setup check immediately after login or signup
// If you're using an Auth flow (Firebase/Supabase), go to the screen user lands on after authentication
// Let's assume that is `AuthGate.dart` (or similar)

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../home/home_screen.dart';
import 'profile_setup_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<bool> hasProfile(String userId) async {
    final supabase = Supabase.instance.client;
    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return response != null;
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<bool>(
      future: hasProfile(user.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.purple)),
          );
        }

        if (snapshot.data == true) {
          return const HomeScreen();
        } else {
          return const ProfileSetupScreen();
        }
      },
    );
  }
}
