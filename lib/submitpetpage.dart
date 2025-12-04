import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/user.dart';


class SubmitPetPage extends StatefulWidget {
  final User user;
  const SubmitPetPage({super.key, required this.user});

  @override
  State<SubmitPetPage> createState() => _SubmitPetPageState();
}

class _SubmitPetPageState extends State<SubmitPetPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController petNameC = TextEditingController();
  String petType = 'Cat';
  String category = 'Adoption';
  TextEditingController descC = TextEditingController();
  String lat = '';
  String lng = '';

  List<XFile> pickedImages = [];
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fillLocation();
  }

  Future<void> _fillLocation() async {
    // request permission and get location
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // location services are not enabled
      setState(() {
        lat = '';
        lng = '';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // permissions are denied
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // permissions are denied forever
      return;
    }

    final p = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    setState(() {
      lat = p.latitude.toString();
      lng = p.longitude.toString();
    });
  }

  Future<void> pickImage() async {
    if (pickedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Max 3 images allowed')));
      return;
    }
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (file != null) {
      setState(() {
        pickedImages.add(file);
      });
    }
  }

  void removeImage(int idx) {
    setState(() {
      pickedImages.removeAt(idx);
    });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (pickedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one image')));
      return;
    }
    if (lat.isEmpty || lng.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not available')));
      return;
    }

    setState(() => isLoading = true);

    // encode images to base64
    List<String> imagesBase64 = [];
    for (var f in pickedImages) {
      final bytes = await File(f.path).readAsBytes();
      imagesBase64.add(base64Encode(bytes));
    }

    final url = Uri.parse('${MyConfig.baseUrl}${MyConfig.backend}/submit_pet.php');

    final body = jsonEncode({
      'user_id': widget.user.userId ?? '0',
      'pet_name': petNameC.text.trim(),
      'pet_type': petType,
      'category': category,
      'description': descC.text.trim(),
      'lat': lat,
      'lng': lng,
      'images': imagesBase64,
    });

    try {
      final resp = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body).timeout(const Duration(seconds: 20));
      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body);
        if (j['success'] == true) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pet submitted successfully')));
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(j['message'] ?? 'Submission failed')));
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Server error: ${resp.statusCode}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Network error: $e')));
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    petNameC.dispose();
    descC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // follow your original UI style
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Pet')),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: MediaQuery.of(context).size.width > 400 ? 400 : MediaQuery.of(context).size.width,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: petNameC,
                      decoration: const InputDecoration(labelText: 'Pet Name', border: OutlineInputBorder()),
                      validator: (v) => v==null || v.trim().isEmpty ? 'Enter pet name' : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: petType,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                        DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                        DropdownMenuItem(value: 'Rabbit', child: Text('Rabbit')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => petType = v ?? 'Cat'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'Adoption', child: Text('Adoption')),
                        DropdownMenuItem(value: 'Donation', child: Text('Donation')),
                        DropdownMenuItem(value: 'Help/Rescue', child: Text('Help/Rescue')),
                      ],
                      onChanged: (v) => setState(() => category = v ?? 'Adoption'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: descC,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                      validator: (v) => v==null || v.trim().length < 10 ? 'Minimum 10 characters' : null,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: Text('Lat: ${lat.isEmpty ? "..." : lat}')),
                        const SizedBox(width: 10),
                        Expanded(child: Text('Lng: ${lng.isEmpty ? "..." : lng}')),
                        IconButton(onPressed: _fillLocation, icon: const Icon(Icons.my_location)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // image previews
                    Align(alignment: Alignment.centerLeft, child: const Text('Images (max 3):')),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < pickedImages.length; i++)
                          Stack(
                            children: [
                              Image.file(File(pickedImages[i].path), width: 100, height: 100, fit: BoxFit.cover),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () => removeImage(i),
                                  child: Container(color: Colors.black54, child: const Icon(Icons.close, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        if (pickedImages.length < 3)
                          GestureDetector(
                            onTap: pickImage,
                            child: Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                              child: const Icon(Icons.add_a_photo, size: 36),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : submit,
                        child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
