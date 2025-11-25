import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/loginpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late double width;
  bool visible = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (width > 400) width = 400;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
        title: const Text("Register Page")),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: SizedBox(
              width: width,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      "assets/images/pawpal.png",
                      scale: 4.5,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // EMAIL
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // NAME
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // PHONE
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Phone",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => visible = !visible);
                        },
                        icon: const Icon(Icons.visibility),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),

                  // CONFIRM PASSWORD
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: visible,
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => visible = !visible);
                        },
                        icon: const Icon(Icons.visibility),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // REGISTER BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        registerDialog();
                      },
                      child: const Text("Register"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // LOGIN LINK
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text("Already have an account? Login here"),
                  ),

                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // VALIDATION + CONFIRMATION DIALOG
  void registerDialog() {
    String email = emailController.text.trim();
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (email.isEmpty || name.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    if (!RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email format")),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Register this account?"),
        content: const Text("Are you sure you want to register?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              registerUser(name, email, password, phone);
            },
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  // REGISTER HTTP REQUEST
  void registerUser(String name, String email, String password,  String phone) async {
    setState(() => isLoading = true);

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(
          children: const [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Registering..."),
          ],
        ),
      ),
    );

    await http
        .post(
          Uri.parse("${MyConfig.baseUrl}/server/backend/register_user.php"),
          body: {
            "email": email,
            "name": name,
            "phone": phone,
            "password": password
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            var res = jsonDecode(response.body);
            log(response.body);

            if (res["status"] == "success") {
              Navigator.pop(context); // close loading
              setState(() => isLoading = false);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Registration successful")),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            } else {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res["message"])),
              );
            }
          } else {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Registration failed. Please try again.")),
            );
          }
        })
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Request timed out. Try again.")),
            );
          },
        );

    setState(() => isLoading = false);
  }
}
