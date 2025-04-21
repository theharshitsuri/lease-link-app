import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _rentController = TextEditingController();
  final _locationController = TextEditingController();
  final _descController = TextEditingController();
  final _locationFocus = FocusNode();

  String _genderPref = 'Any';
  DateTime? _availableDate;
  bool _isLoading = false;

  List<File> _selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  String? _fullAddress;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _titleController.dispose();
    _rentController.dispose();
    _locationController.dispose();
    _descController.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((xfile) => File(xfile.path)).toList();
      });
    }
  }

  Future<List<String>> _uploadImages(List<File> files) async {
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

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate() || _availableDate == null || _latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields including location.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        uploadedImageUrls = await _uploadImages(_selectedImages);
      }

      await Supabase.instance.client.from('listings').insert({
        'title': _titleController.text.trim(),
        'location': _fullAddress ?? _locationController.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'rent': double.parse(_rentController.text.trim()),
        'description': _descController.text.trim(),
        'gender': _genderPref,
        'available_from': DateFormat.yMMMMd().format(_availableDate!),
        'user_id': Supabase.instance.client.auth.currentUser?.id,
        'images': uploadedImageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing added!')),
      );

      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Add Listing'),
          backgroundColor: Colors.black,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      height: 250,
                      width: isWide ? 600 : double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                        image: _selectedImages.isNotEmpty
                            ? DecorationImage(
                                image: FileImage(_selectedImages.first),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _selectedImages.isEmpty
                          ? const Center(
                              child: Text(
                                'Tap to upload images',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : null,
                    ),
                  ),
                  Form(
                    key: _formKey,
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    _buildTextField(_titleController, 'Title'),
                                    _buildTextField(_rentController, 'Rent (\$)', keyboardType: TextInputType.number),
                                    _buildTextField(_descController, 'Description', maxLines: 4),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  children: [
                                    GooglePlaceAutoCompleteTextField(
                                      textEditingController: _locationController,
                                      focusNode: _locationFocus,
                                      googleAPIKey: "AIzaSyAhxj35WP_-sm_0C23hcQNYS5BqmNl09Cw",
                                      inputDecoration: _inputDecoration('Location'),
                                      debounceTime: 400,
                                      isLatLngRequired: true,
                                      getPlaceDetailWithLatLng: (Prediction prediction) {
                                        _fullAddress = prediction.description;
                                        _latitude = double.tryParse(prediction.lat ?? '');
                                        _longitude = double.tryParse(prediction.lng ?? '');
                                        _locationController.text = prediction.description ?? '';
                                        _locationFocus.unfocus();
                                      },
                                      itemClick: (Prediction prediction) {
                                        _locationController.text = prediction.description ?? '';
                                        _locationFocus.unfocus();
                                      },
                                      seperatedBuilder: const Divider(height: 1, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 12),
                                    DropdownButtonFormField<String>(
                                      dropdownColor: Colors.black,
                                      value: _genderPref,
                                      items: ['Any', 'Male', 'Female']
                                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                          .toList(),
                                      onChanged: (value) => setState(() => _genderPref = value!),
                                      decoration: _inputDecoration('Gender Preference'),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () async {
                                        DateTime? picked = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
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
                                        style: const TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              _buildTextField(_titleController, 'Title'),
                              _buildTextField(_rentController, 'Rent (\$)', keyboardType: TextInputType.number),
                              GooglePlaceAutoCompleteTextField(
                                textEditingController: _locationController,
                                focusNode: _locationFocus,
                                googleAPIKey: "AIzaSyAhxj35WP_-sm_0C23hcQNYS5BqmNl09Cw",
                                inputDecoration: _inputDecoration('Location'),
                                debounceTime: 400,
                                isLatLngRequired: true,
                                getPlaceDetailWithLatLng: (Prediction prediction) {
                                  _fullAddress = prediction.description;
                                  _latitude = double.tryParse(prediction.lat ?? '');
                                  _longitude = double.tryParse(prediction.lng ?? '');
                                  _locationController.text = prediction.description ?? '';
                                  _locationFocus.unfocus();
                                },
                                itemClick: (Prediction prediction) {
                                  _locationController.text = prediction.description ?? '';
                                  _locationFocus.unfocus();
                                },
                                seperatedBuilder: const Divider(height: 1, color: Colors.grey),
                              ),
                              const SizedBox(height: 12),
                              _buildTextField(_descController, 'Description', maxLines: 4),
                              DropdownButtonFormField<String>(
                                dropdownColor: Colors.black,
                                value: _genderPref,
                                items: ['Any', 'Male', 'Female']
                                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                    .toList(),
                                onChanged: (value) => setState(() => _genderPref = value!),
                                decoration: _inputDecoration('Gender Preference'),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
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
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitListing,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Listing', style: TextStyle(fontSize: 18, color: Colors.white)),
                  )
                ],
              ),
            ),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white70),
      ),
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
