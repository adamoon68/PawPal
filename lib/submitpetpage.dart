import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pawpal/user.dart';
import 'package:pawpal/myconfig.dart';

class SubmitPetPage extends StatefulWidget {
  final User? user;
  const SubmitPetPage({super.key, required this.user});

  @override
  State<SubmitPetPage> createState() => _SubmitPetPageState();
}

class _SubmitPetPageState extends State<SubmitPetPage> {
  List<String> petTypes = ['Cat', 'Dog', 'Bird', 'Rabbit', 'Other'];
  List<String> categories = [
    'Adoption',
    'Lost',
    'Donation Request',
  ];
  List<String> genders = ['Male', 'Female', 'Unknown'];

  TextEditingController petNameController = TextEditingController();
  TextEditingController petAgeController = TextEditingController();
  TextEditingController petHealthController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();

  String selectedpet = 'Cat';
  String selectedcategory = 'Adoption';
  String selectedgender = 'Male';

  List<File> images = [];
  List<Uint8List> webImages = [];
  late double height, width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (width > 600) width = 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Pet'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (checkImageLimit()) return;
                      if (kIsWeb)
                        openGallery();
                      else
                        pickimagedialog();
                    },
                    child: Container(
                      width: width,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: (images.isEmpty && webImages.isEmpty)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.camera_alt, size: 50),
                                Text("Tap to add images"),
                              ],
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: kIsWeb
                                  ? webImages.length
                                  : images.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: kIsWeb
                                      ? Image.memory(webImages[index])
                                      : Image.file(images[index]),
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: petNameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: petAgeController,
                    decoration: const InputDecoration(
                      labelText: 'Age (e.g. 2 months)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    value: selectedgender,
                    items: genders
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedgender = v!),
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    value: selectedpet,
                    items: petTypes
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedpet = v!),
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField(
                    value: selectedcategory,
                    items: categories
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => selectedcategory = v!),
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: petHealthController,
                    decoration: const InputDecoration(
                      labelText: 'Health (e.g. Vaccinated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: latController,
                          decoration: const InputDecoration(
                            labelText: 'Lat',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: lngController,
                          decoration: const InputDecoration(
                            labelText: 'Lng',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _determinePosition,
                        icon: const Icon(Icons.location_on),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: showSubmitDialog,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("Submit"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool checkImageLimit() => (kIsWeb ? webImages.length : images.length) >= 3;

  void pickimagedialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                openCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                openGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      images.add(File(pickedFile.path));
      cropImage(images.length - 1);
    }
  }

  Future<void> openGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        var bytes = await pickedFile.readAsBytes();
        setState(() => webImages.add(bytes));
      } else {
        images.add(File(pickedFile.path));
        cropImage(images.length - 1);
      }
    }
  }

  Future<void> cropImage(int index) async {
    if (kIsWeb) return;
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: images[index].path,
      aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
    );
    if (croppedFile != null)
      setState(() => images[index] = File(croppedFile.path));
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      latController.text = position.latitude.toString();
      lngController.text = position.longitude.toString();
    });
  }

  void showSubmitDialog() {
    if (petNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        latController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Incomplete fields")));
      return;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              submitPet();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Future<void> submitPet() async {
    List<String> base64Images = [];
    if (kIsWeb) {
      for (var img in webImages) base64Images.add(base64Encode(img));
    } else {
      for (var img in images)
        base64Images.add(base64Encode(img.readAsBytesSync()));
    }

    await http
        .post(
          Uri.parse('${MyConfig.baseUrl}${MyConfig.backend}/submit_pet.php'),
          body: {
            'user_id': widget.user?.userId,
            'pet_name': petNameController.text,
            'pet_age': petAgeController.text,
            'pet_gender': selectedgender,
            'pet_type': selectedpet,
            'category': selectedcategory,
            'pet_health': petHealthController.text,
            'description': descriptionController.text,
            'images': jsonEncode(base64Images),
            'lat': latController.text,
            'lng': lngController.text,
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            var res = jsonDecode(response.body);
            if (res['status'] == 'success') {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Success")));
              Navigator.pop(context);
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(res['message'])));
            }
          }
        });
  }
}
