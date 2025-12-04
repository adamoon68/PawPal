import 'package:flutter/material.dart';
import 'package:pawpal/user.dart';
import 'package:pawpal/loginpage.dart';
import 'package:pawpal/submitpetpage.dart';
import 'package:pawpal/mypetspage.dart';
import 'package:pawpal/mydrawer.dart';

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PawPal Home"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),

      // ADD DRAWER
      drawer: MyDrawer(user: user),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Welcome, ${user.userName}!",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            // BUTTON: SUBMIT PET
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubmitPetPage(user: user),
                  ),
                );
              },
              icon: const Icon(Icons.pets),
              label: const Text("Submit a Pet"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),

            const SizedBox(height: 15),

            // BUTTON: VIEW MY PETS
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyPetsPage(user: user),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text("My Pets"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
