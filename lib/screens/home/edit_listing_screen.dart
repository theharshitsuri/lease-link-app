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
  final String availableTo; // ✅ Added

  const EditListingScreen({
    super.key,
    required this.listingId,
    required this.title,
    required this.location,
    required this.rent,
    required this.availableFrom,
    required this.description,
    required this.gender,
    required this.availableTo,
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
  DateTime? _availableFrom;
  DateTime? _availableTo; // ✅ Added
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
    _availableFrom = DateTime.tryParse(widget.availableFrom);
    _availableTo = DateTime.tryParse(widget.availableTo); // ✅ Parse To
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

      final bytes = await image.readAsBytes();
      await supabase.storage
          .from('listing-images')
          .uploadBinary(fileName, bytes, fileOptions: const FileOptions(upsert: true));

      final imageUrl = supabase.storage.from('listing-images').getPublicUrl(fileName);
      urls.add(imageUrl);
    }
    return urls;
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      List<String> uploaded = await _uploadNewImages(_newImages);
      final allImages = [..._existingImages, ...uploaded];

      await supabase.from('listings').update({
        'title': _titleController.text.trim(),
        'location': _locationController.text.trim(),
        'rent': double.parse(_rentController.text.trim()),
        'description': _descriptionController.text.trim(),
        'gender': _genderPref,
        'available_from': _availableFrom!.toIso8601String(),
        'available_to': _availableTo!.toIso8601String(), // ✅ Added
        'images': allImages,
      }).eq('id', widget.listingId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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

  void _removeExistingImage(int index) => setState(() => _existingImages.removeAt(index));
  void _removeNewImage(int index) => setState(() => _newImages.removeAt(index));

  Widget _buildImageList(List images, {required bool isNew}) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final image = images[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: isNew
                    ? Image.file(image, width: 100, height: 100, fit: BoxFit.cover)
                    : Image.network(image, width: 100, height: 100, fit: BoxFit.cover),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => isNew ? _removeNewImage(index) : _removeExistingImage(index),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_existingImages.isNotEmpty) ...[
          const Text('Existing Images', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          _buildImageList(_existingImages, isNew: false),
          const SizedBox(height: 20),
        ],
        if (_newImages.isNotEmpty) ...[
          const Text('New Images', style: TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          _buildImageList(_newImages, isNew: true),
          const SizedBox(height: 20),
        ],
        Center(
          child: ElevatedButton(
            onPressed: _pickNewImages,
            child: const Text('Add New Images'),
          ),
        ),
        const SizedBox(height: 20),
      ],
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

  Widget _buildFormSection() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
                initialDate: _availableFrom ?? DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2026),
              );
              if (picked != null) setState(() => _availableFrom = picked);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text(
              _availableFrom == null
                  ? 'Select Available From Date'
                  : 'Available From: ${DateFormat.yMMMMd().format(_availableFrom!)}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _availableTo ?? DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2026),
              );
              if (picked != null) setState(() => _availableTo = picked);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: Text(
              _availableTo == null
                  ? 'Select Available To Date'
                  : 'Available To: ${DateFormat.yMMMMd().format(_availableTo!)}',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 700;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Listing'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: isWeb
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildImageSection()),
                  const SizedBox(width: 40),
                  Expanded(child: SingleChildScrollView(child: _buildFormSection())),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    _buildImageSection(),
                    _buildFormSection(),
                  ],
                ),
              ),
      ),
    );
  }
}
