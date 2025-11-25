import 'package:flutter/material.dart';
import 'package:pawpal/user.dart';

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PawPal Home")),
      body: Center(
        child: Text(
          "Welcome, ${user.userName}!",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
