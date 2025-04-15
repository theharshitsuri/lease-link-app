import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _gender = 'Male';
  File? _newImage;
  String? _existingImageUrl;
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

    if (response != null) {
      _nameController.text = response['name'] ?? '';
      _ageController.text = response['age']?.toString() ?? '';
      _gender = response['gender'] ?? 'Male';
      _existingImageUrl = response['profile_image_url'];
    }

    setState(() => _isLoading = false);
  }

  Future<String?> _uploadImage(File file) async {
    final ext = path.extension(file.path);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final filePath = 'profiles/$fileName';

    final bytes = await file.readAsBytes();
    await supabase.storage
        .from('profile-images')
        .uploadBinary(filePath, bytes, fileOptions: const FileOptions(upsert: true));

    return supabase.storage.from('profile-images').getPublicUrl(filePath);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    String? uploadedImageUrl = _existingImageUrl;
    if (_newImage != null) {
      uploadedImageUrl = await _uploadImage(_newImage!);
    }

    await supabase.from('profiles').update({
      'name': _nameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'gender': _gender,
      'profile_image_url': uploadedImageUrl,
    }).eq('id', userId);

    if (mounted) {
      Navigator.pop(context); // Go back to profile screen
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _newImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: _newImage != null
                            ? FileImage(_newImage!)
                            : (_existingImageUrl != null
                                ? NetworkImage(_existingImageUrl!) as ImageProvider
                                : null),
                        child: _newImage == null && _existingImageUrl == null
                            ? const Icon(Icons.add_a_photo, color: Colors.white70)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Name"),
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDecoration("Age"),
                      validator: (val) => val!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: _inputDecoration("Gender"),
                      dropdownColor: Colors.black,
                      style: const TextStyle(color: Colors.white),
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) => setState(() => _gender = val!),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      ),
                      child: const Text('Save', style: TextStyle(fontSize: 16)),
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.purple),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );
}
