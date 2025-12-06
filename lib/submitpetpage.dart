import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart'; // For kIsWeb
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
  // Lists
  List<String> petTypes = [
    'Cat', 'Dog', 'Bird', 'Rabbit', 'Other'
  ];
  List<String> categories = [
    'Adoption', 'Lost', 'Found', 'Donation Request', 'Help / Rescue '
  ];

  // Controllers
  TextEditingController petNameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();

  // Selections
  String selectedpet = 'Cat';
  String selectedcategory = 'Adoption';

  // Image Handling
  List<File> images = []; 
  List<Uint8List> webImages = []; 
  
  // UI Dimensions
  late double height, width;

  @override
  Widget build(BuildContext context) {
    // Responsive Logic
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (width > 600) {
      width = 600;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Pet Page'),
        backgroundColor: Color(0xFF607D8B), 
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // IMAGE PICKER CONTAINER
                  GestureDetector(
                    onTap: () {
                      
                      if (checkImageLimit()) {
                        return; 
                      }

                      if (kIsWeb) {
                        openGallery(); 
                      } else {
                        pickimagedialog();
                      }
                    },
                    child: Container(
                      width: width,
                      height: height / 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade400),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: (images.isEmpty && webImages.isEmpty)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.camera_alt, size: 80, color: Colors.grey),
                                SizedBox(height: 10),
                                Text(
                                  "Tap to add image (Max 3)",
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            )
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: kIsWeb ? webImages.length : images.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: kIsWeb
                                            ? Image.memory(webImages[index], fit: BoxFit.cover, width: width * 0.5)
                                            : Image.file(images[index], fit: BoxFit.cover, width: width * 0.5),
                                      ),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (kIsWeb) {
                                                webImages.removeAt(index);
                                              } else {
                                                images.removeAt(index);
                                              }
                                            });
                                          },
                                          child: const CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Colors.red,
                                            child: Icon(Icons.close, size: 16, color: Colors.white),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),

                  // FORM FIELDS
                  TextField(
                    controller: petNameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Pet Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    value: selectedpet,
                    items: petTypes.map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (newValue) => setState(() => selectedpet = newValue!),
                  ),

                  const SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                    ),
                    value: selectedcategory,
                    items: categories.map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (newValue) => setState(() => selectedcategory = newValue!),
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
                            labelText: 'Latitude',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          controller: lngController,
                          decoration: const InputDecoration(
                            labelText: 'Longitude',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _determinePosition,
                        icon: const Icon(Icons.my_location, color: Colors.blueGrey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey, 
                      minimumSize: Size(width, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      showSubmitDialog();
                    },
                    child: const Text(
                      'Submit',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // FUNCTIONS

  bool checkImageLimit() {
    int currentCount = kIsWeb ? webImages.length : images.length;
    if (currentCount >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maximum 3 images allowed"),
          backgroundColor: Colors.red,
        ),
      );
      return true; 
    }
    return false; 
  }
// IMAGE PICKER DIALOG
  void pickimagedialog() {
    
    if (checkImageLimit()) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
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
        );
      },
    );
  }
// OPEN CAMERA FUNCTION
  Future<void> openCamera() async {

    if (checkImageLimit()) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

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
// IMAGE PICKER - GALLERY
  Future<void> openGallery() async {

    if (checkImageLimit()) return;

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
// IMAGE CROPPING FUNCTION
  Future<void> cropImage(int index) async {
    if (kIsWeb) return; 
    
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: images[index].path,
      aspectRatio: const CropAspectRatio(ratioX: 5, ratioY: 3),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Your Image',
          toolbarColor: Colors.deepPurple,
          toolbarWidgetColor: Colors.white,
        ),
        IOSUiSettings(title: 'Cropper'),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        images[index] = File(croppedFile.path);
      });
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      latController.text = position.latitude.toString();
      lngController.text = position.longitude.toString();
    });
  }

  void showSubmitDialog() {
    if (petNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter pet name"), backgroundColor: Colors.red));
      return;
    }
    
    if ((!kIsWeb && images.isEmpty) || (kIsWeb && webImages.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select at least one image"), backgroundColor: Colors.red));
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter description"), backgroundColor: Colors.red));
      return;
    }
    
    if (latController.text.isEmpty || lngController.text.isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select location"), backgroundColor: Colors.red));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Submit Pet'),
          content: const Text('Are you sure you want to submit this pet?'),
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
        );
      },
    );
  }

  Future<void> submitPet() async {
    List<String> base64Images = [];
    
    if (kIsWeb) {
      for (var img in webImages) {
        base64Images.add(base64Encode(img));
      }
    } else {
      for (var img in images) {
        base64Images.add(base64Encode(img.readAsBytesSync()));
      }
    }

    String petName = petNameController.text.trim();
    String description = descriptionController.text.trim();
    String lat = latController.text.trim();
    String lng = lngController.text.trim();

    await http.post(
      Uri.parse('${MyConfig.baseUrl}${MyConfig.backend}/submit_pet.php'),
      body: {
        'user_id': widget.user?.userId,
        'pet_name': petName,
        'pet_type': selectedpet,
        'category': selectedcategory,
        'description': description,
        'images': jsonEncode(base64Images),
        'lat': lat,
        'lng': lng,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var jsonResponse = response.body;
        var resarray = jsonDecode(jsonResponse);
        if (resarray['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pet submitted successfully"), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resarray['message']), backgroundColor: Colors.red),
          );
        }
      }
    });
  }
}