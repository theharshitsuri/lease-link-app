import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/auth/profile_setup_screen.dart'; // 👈 Add this import

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zevjpoawnfmkrbgyualp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpldmpwb2F3bmZta3JiZ3l1YWxwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQwNjY3MTQsImV4cCI6MjA1OTY0MjcxNH0.uh8eqnRapgsI61UHxKO4JLpd9veLLRg1TdI89ogkuvU',
  );

  runApp(const LeaseLinkApp());
}

class LeaseLinkApp extends StatefulWidget {
  const LeaseLinkApp({super.key});

  @override
  State<LeaseLinkApp> createState() => _LeaseLinkAppState();
}

class _LeaseLinkAppState extends State<LeaseLinkApp> {
  @override
  void initState() {
    super.initState();

    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;

      if (event == AuthChangeEvent.signedOut || event == AuthChangeEvent.userDeleted) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      } else if (event == AuthChangeEvent.signedIn) {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) return;

        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .maybeSingle();

        if (profile == null) {
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/setup', (route) => false);
        } else {
          navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'LeaseLink',
      theme: ThemeData.dark(),
      home: session == null ? const WelcomeScreen() : const MainNavScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavScreen(),
        '/setup': (context) => const ProfileSetupScreen(), // 👈 Add this route
      },
    );
  }
}
