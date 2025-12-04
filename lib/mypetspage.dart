import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/pet.dart';
import 'package:pawpal/user.dart';

class MyPetsPage extends StatefulWidget {
  final User user;
  const MyPetsPage({super.key, required this.user});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  List<Pet> pets = [];
  String status = 'Loading...';

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  Future<void> loadPets() async {
    final url = Uri.parse('${MyConfig.baseUrl}${MyConfig.backend}/get_my_pets.php');
    try {
      final resp = await http.post(url, body: {'user_id': widget.user.userId ?? '0'}).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body);
        if (j['success'] == true) {
          final data = j['data'] as List;
          pets = data.map((e) => Pet.fromJson(e)).toList();
          if (pets.isEmpty) status = 'No submissions yet.';
        } else {
          status = j['message'] ?? 'No submissions yet.';
        }
      } else {
        status = 'Server error ${resp.statusCode}';
      }
    } catch (e) {
      status = 'Network error';
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Submissions')),
      body: pets.isEmpty
          ? Center(child: Text(status))
          : ListView.builder(
              itemCount: pets.length,
              itemBuilder: (_, i) {
                final p = pets[i];
                final thumb = (p.imagePaths != null && p.imagePaths!.isNotEmpty)
                    ? '${MyConfig.baseUrl}${MyConfig.backend}/uploads/pets/${p.imagePaths![0]}'
                    : null;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    leading: thumb == null ? const SizedBox(width: 60, child: Icon(Icons.pets)) : Image.network(thumb, width: 60, height: 60, fit: BoxFit.cover),
                    title: Text(p.petName ?? ''),
                    subtitle: Text('${p.petType} • ${p.category}\n${(p.description ?? '').length > 60 ? (p.description!.substring(0, 60) + '...') : p.description ?? ''}'),
                    isThreeLine: true,
                    
                  ),
                );
              },
            ),
    );
  }
}
