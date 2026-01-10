import 'package:flutter/material.dart';
import 'package:pawpal/user.dart';
import 'package:pawpal/loginpage.dart';
import 'package:pawpal/mypetspage.dart';
import 'package:pawpal/submitpetpage.dart';
import 'package:pawpal/publicpetspage.dart';
import 'package:pawpal/mydonationspage.dart';
import 'package:pawpal/profilepage.dart';
import 'package:pawpal/myconfig.dart';

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
            currentAccountPicture: CircleAvatar(
              backgroundImage:
                  (user?.profileImage != null && user!.profileImage!.isNotEmpty)
                  ? NetworkImage(
                      "${MyConfig.baseUrl}${MyConfig.backend}/uploads/profile/${user!.profileImage}",
                    )
                  : const AssetImage("assets/images/pawpal.png")
                        as ImageProvider,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Browse Pets'),
            onTap: () {
              Navigator.pop(context);
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PublicPetsPage(user: user!),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets),
            title: const Text('My Submissions'),
            onTap: () {
              Navigator.pop(context);
              if (user == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MyPetsPage(user: user!)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Register Pet'),
            onTap: () {
              Navigator.pop(context);
              if (user == null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SubmitPetPage(user: user!)),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Donation History'),
            onTap: () {
              Navigator.pop(context);
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyDonationsPage(user: user!),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              if (user != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage(user: user!)),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
