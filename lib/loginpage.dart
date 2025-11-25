import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/user.dart';
import 'package:pawpal/registerpage.dart';
import 'package:pawpal/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool visible = true;
  bool isChecked = false;
  double width = 400;

  late User user;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    if (width > 400) width = 400;

    return Scaffold(
      appBar: AppBar(title: const Text("Login Page")),
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

                  // REMEMBER ME
                  Row(
                    children: [
                      const Text("Remember Me"),
                      Checkbox(
                        value: isChecked,
                        onChanged: (value) {
                          isChecked = value!;
                          setState(() {});

                          if (isChecked) {
                            if (emailController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                              prefUpdate(true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Preferences Stored"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              isChecked = false;
                              setState(() {});
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please fill your email and password"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          } else {
                            prefUpdate(false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Preferences Removed"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            emailController.clear();
                            passwordController.clear();
                            setState(() {});
                          }
                        },
                      ),
                    ],
                  ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loginUser,
                      child: const Text("Login"),
                    ),
                  ),

                  const SizedBox(height: 5),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                    child: const Text("Don't have an account? Register here."),
                  ),

                  const SizedBox(height: 5),
                  const Text("Forgot Password?"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // SAVE / REMOVE REMEMBER ME
  void prefUpdate(bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      prefs.setString("email", emailController.text);
      prefs.setString("password", passwordController.text);
      prefs.setBool("rememberMe", true);
    } else {
      prefs.remove("email");
      prefs.remove("password");
      prefs.remove("rememberMe");
    }
  }

  // LOAD SAVED EMAIL + PASSWORD
  void loadPreferences() {
    SharedPreferences.getInstance().then((prefs) {
      bool? rememberMe = prefs.getBool("rememberMe");

      if (rememberMe == true) {
        emailController.text = prefs.getString("email") ?? "";
        passwordController.text = prefs.getString("password") ?? "";
        isChecked = true;
        setState(() {});
      }
    });
  }

  // LOGIN USER API
  void loginUser() {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in email and password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    http
        .post(
      Uri.parse("${MyConfig.baseUrl}/server/backend/login_user.php"),
      body: {"email": email, "password": password},
    )
        .then((response) {
      if (response.statusCode == 200) {
        var res = jsonDecode(response.body);

        if (res["status"] == "success") {
          user = User.fromJson(res["data"][0]);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Login successful"),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomePage(user: user),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res["message"]),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Login failed: ${response.statusCode}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}
