import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_nav_screen.dart';

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

    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.signedOut || event == AuthChangeEvent.userDeleted) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (route) => false);
      } else if (event == AuthChangeEvent.signedIn) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
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
      },
    );
  }
}

