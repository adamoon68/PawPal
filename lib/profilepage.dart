import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/user.dart';

class ProfilePage extends StatefulWidget {
  final User user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  File? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user.userName);
    phoneCtrl = TextEditingController(text: widget.user.userPhone);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and Phone cannot be empty")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String base64Image = _image != null
          ? base64Encode(_image!.readAsBytesSync())
          : "";

      var resp = await http.post(
        Uri.parse("${MyConfig.baseUrl}${MyConfig.backend}/update_profile.php"),
        body: {
          "user_id": widget.user.userId,
          "name": nameCtrl.text,
          "phone": phoneCtrl.text,
          "image": base64Image,
        },
      );

      if (resp.statusCode == 200) {
        var data = jsonDecode(resp.body);
        if (data['status'] == 'success') {
          // --- FIX START: UPDATE LOCAL USER DATA ---
          setState(() {
            widget.user.userName = nameCtrl.text;
            widget.user.userPhone = phoneCtrl.text;

            if (data['data'] != null && data['data']['filename'] != null) {
              widget.user.profileImage = data['data']['filename'];

              _image = null;
            }
          });
          // --- FIX END ---

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile Updated Successfully")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Update Failed: ${data['message']}")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server Error: ${resp.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        // Added scroll view to prevent overflow
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : (widget.user.profileImage != null &&
                              widget.user.profileImage!.isNotEmpty
                          ? NetworkImage(
                                  "${MyConfig.baseUrl}${MyConfig.backend}/uploads/profile/${widget.user.profileImage}",
                                )
                                as ImageProvider
                          : const AssetImage("assets/images/pawpal.png")),
                child:
                    _image == null &&
                        (widget.user.profileImage == null ||
                            widget.user.profileImage!.isEmpty)
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey)
                    : null,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Tap image to change",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone",
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email),
                hintText: widget.user.userEmail,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
