import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

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

  late String _genderPref;
  DateTime? _availableDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _locationController = TextEditingController(text: widget.location);
    _rentController = TextEditingController(text: widget.rent);
    _descriptionController = TextEditingController(text: widget.description);
    _genderPref = widget.gender;
    _availableDate = DateFormat.yMMMMd().parse(widget.availableFrom);
  }

  Future<void> _updateListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      await supabase.from('listings').update({
        'title': _titleController.text.trim(),
        'location': _locationController.text.trim(),
        'rent': double.parse(_rentController.text.trim()),
        'description': _descriptionController.text.trim(),
        'gender': _genderPref,
        'available_from': DateFormat.yMMMMd().format(_availableDate!),
      }).eq('id', widget.listingId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Listing updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Listing'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
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
                items: ['Any', 'Male', 'Female']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => _genderPref = val!),
                decoration: const InputDecoration(labelText: 'Gender Preference'),
                style: const TextStyle(color: Colors.white),
              ),

              const SizedBox(height: 16),
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
                    : const Text('Update Listing',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
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
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white30)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.purple)),
        ),
        validator: (val) =>
            val == null || val.trim().isEmpty ? 'Required' : null,
      ),
    );
  }
}
