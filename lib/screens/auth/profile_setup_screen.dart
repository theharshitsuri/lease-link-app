import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main_nav_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final profile = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (profile != null) {
      if (profile['name'] != null) {
        _nameController.text = profile['name'];
      }
      if (profile['age'] != null) {
        _ageController.text = profile['age'].toString();
      }
      if (profile['gender'] != null) {
        setState(() {
          _gender = profile['gender'];
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<String?> _uploadProfileImage(File file) async {
    final ext = path.extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final filePath = 'profiles/$fileName';

    final bytes = await file.readAsBytes();
    await supabase.storage
        .from('profile-images')
        .uploadBinary(filePath, bytes, fileOptions: const FileOptions(upsert: true));

    return supabase.storage.from('profile-images').getPublicUrl(filePath);
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadProfileImage(_selectedImage!);
    }

    await supabase.from('profiles').upsert({
      'id': userId,
      'name': _nameController.text.trim(),
      'age': int.parse(_ageController.text.trim()),
      'gender': _gender,
      'profile_image_url': imageUrl,
    });

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavScreen()),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Set Up Your Profile'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _selectedImage != null ? FileImage(_selectedImage!) : null,
                  backgroundColor: Colors.grey[800],
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo, color: Colors.white70)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Name'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Age'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Required';
                  final age = int.tryParse(val.trim());
                  if (age == null || age < 16 || age > 100) return 'Enter a valid age';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _gender,
                dropdownColor: Colors.black,
                decoration: _inputDecoration('Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _gender = val!),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Continue', style: TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
