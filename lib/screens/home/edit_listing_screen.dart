import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class EditListingScreen extends StatefulWidget {
  final String listingId;
  final String title;
  final String location;
  final String rent;
  final String availableFrom;
  final String description;
  final String gender;

  const EditListingScreen({
    super.key,
    required this.listingId,
    required this.title,
    required this.location,
    required this.rent,
    required this.availableFrom,
    required this.description,
    required this.gender,
  });

  @override
  State<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends State<EditListingScreen> {
  final supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _rentController;
  late TextEditingController _descriptionController;

  List<dynamic> _existingImages = [];
  List<File> _newImages = [];
  String _genderPref = 'Any';
  DateTime? _availableDate;
  bool _isSaving = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _locationController = TextEditingController(text: widget.location);
    _rentController = TextEditingController(text: widget.rent);
    _descriptionController = TextEditingController(text: widget.description);
    _genderPref = widget.gender;
    _availableDate = DateFormat.yMMMMd().parse(widget.availableFrom);
    fetchExistingImages();
  }

  Future<void> fetchExistingImages() async {
    final response = await supabase
        .from('listings')
        .select('images')
        .eq('id', widget.listingId)
        .single();

    setState(() {
      _existingImages = response['images'] ?? [];
    });
  }

  Future<List<String>> _uploadNewImages(List<File> files) async {
    final urls = <String>[];
    for (final image in files) {
      final fileExt = path.extension(image.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final filePath = fileName;

      final bytes = await image.readAsBytes();
      await Supabase.instance.client.storage
          .from('listing-images')
          .uploadBinary(filePath, bytes, fileOptions: const FileOptions(upsert: true));

      final imageUrl = Supabase.instance.client.storage
          .from('listing-images')
          .getPublicUrl(filePath);
      urls.add(imageUrl);
    }
    return urls;
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      List<String> uploadedNew = await _uploadNewImages(_newImages);

      final allImages = [..._existingImages, ...uploadedNew];

      await supabase.from('listings').update({
        'title': _titleController.text.trim(),
        'location': _locationController.text.trim(),
        'rent': double.parse(_rentController.text.trim()),
        'description': _descriptionController.text.trim(),
        'gender': _genderPref,
        'available_from': DateFormat.yMMMMd().format(_availableDate!),
        'images': allImages,
      }).eq('id', widget.listingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickNewImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _newImages.addAll(picked.map((x) => File(x.path)));
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Listing'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_existingImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Existing Images', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _existingImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _existingImages[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _removeExistingImage(index),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              if (_newImages.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('New Images', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 100,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _newImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _newImages[index],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red),
                                  onPressed: () => _removeNewImage(index),
                                ),
                              )
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ElevatedButton(
                onPressed: _pickNewImages,
                child: const Text('Add New Images'),
              ),
              const SizedBox(height: 20),
              _buildTextField(_titleController, 'Title'),
              _buildTextField(_rentController, 'Rent (\$)', keyboardType: TextInputType.number),
              _buildTextField(_locationController, 'Location'),
              _buildTextField(_descriptionController, 'Description', maxLines: 4),
              DropdownButtonFormField<String>(
                dropdownColor: Colors.black,
                value: _genderPref,
                decoration: _inputDecoration('Gender Preference'),
                items: ['Any', 'Male', 'Female']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _genderPref = val!),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _availableDate ?? DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2026),
                  );
                  if (picked != null) {
                    setState(() => _availableDate = picked);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: Text(
                  _availableDate == null
                      ? 'Select Available From Date'
                      : 'Available From: ${DateFormat.yMMMMd().format(_availableDate!)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSaving ? null : _updateListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Listing', style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white30),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.purple),
      ),
    );
  }
}
