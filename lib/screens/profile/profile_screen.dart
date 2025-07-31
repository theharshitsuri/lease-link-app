import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../auth/welcome_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    setState(() {
      _profile = response;
      _isLoading = false;
    });
  }

  Future<void> _logout(BuildContext context) async {
    await supabase.auth.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Delete user's listings
      await supabase.from('listings').delete().eq('user_id', userId);

      // 2. Delete user's profile
      await supabase.from('profiles').delete().eq('id', userId);

      // 3. Sign out the user
      await supabase.auth.signOut();

      // 4. Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account and listings deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );

      // 5. Wait a bit so user sees the snackbar
      await Future.delayed(const Duration(seconds: 1));

      // 6. Navigate back to welcome screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting account: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;
    final isWeb = MediaQuery.of(context).size.width > 700;

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.purple)),
      );
    }

    final profileContent = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: _profile?['profile_image_url'] != null
              ? NetworkImage(_profile!['profile_image_url'])
              : null,
          backgroundColor: Colors.purple,
          child: _profile?['profile_image_url'] == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 20),
        Text(
          _profile?['name'] ?? user?.email?.split('@')[0] ?? 'User',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          user?.email ?? '',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 20),
        ListTile(
          leading: const Icon(Icons.edit, color: Colors.white),
          title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            );
            setState(() => _isLoading = true);
            _loadProfile();
          },
        ),
        const Divider(color: Colors.white24),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text('Logout', style: TextStyle(color: Colors.white)),
          onTap: () => _logout(context),
        ),
        const Divider(color: Colors.white24),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Color.fromARGB(255, 255, 255, 255)),
          title: const Text('Delete Account', style: TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
          onTap: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.black,
                title: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
                content: const Text('Are you sure you want to delete your account permanently?', style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await _deleteAccount(context);
            }
          },
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.black,
        elevation: 0,
        surfaceTintColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: isWeb
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: profileContent,
                ),
              )
            : profileContent,
      ),
    );
  }
}
