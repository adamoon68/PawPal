import 'package:flutter/material.dart';
import 'package:pawpal/user.dart';
import 'package:pawpal/loginpage.dart';
import 'package:pawpal/mypetspage.dart';
import 'package:pawpal/submitpetpage.dart';

class MyDrawer extends StatelessWidget {
  final User? user;
  const MyDrawer({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.userName ?? 'Guest'),
            accountEmail: Text(user?.userEmail ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('My Submissions'),
            onTap: () {
              if (user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => MyPetsPage(user: user!)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Submit Pet'),
            onTap: () {
              if (user == null) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                return;
              }
              Navigator.push(context, MaterialPageRoute(builder: (_) => SubmitPetPage(user: user!)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
            },
          ),
        ],
      ),
    );
  }
}
