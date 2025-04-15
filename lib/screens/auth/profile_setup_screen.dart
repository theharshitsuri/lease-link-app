import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

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

    await supabase.from('profiles').insert({
      'id': userId,
      'name': _nameController.text.trim(),
      'age': int.parse(_ageController.text.trim()),
      'gender': _gender,
      'profile_image_url': imageUrl,
    });

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 55,
                  backgroundImage:
                      _selectedImage != null ? FileImage(_selectedImage!) : null,
                  backgroundColor: Colors.grey[850],
                  child: _selectedImage == null
                      ? const Icon(Icons.add_a_photo_rounded, size: 30, color: Colors.white70)
                      : null,
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(_nameController, "Full Name", TextInputType.name),
              const SizedBox(height: 16),
              _buildTextField(_ageController, "Age", TextInputType.number),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                dropdownColor: Colors.grey[900],
                decoration: _inputDecoration('Gender'),
                items: ['Male', 'Female', 'Other']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _gender = val!),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Continue", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, TextInputType keyboardType) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration(label),
      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.grey[900],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      );
}
