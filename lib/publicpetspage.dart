import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal/myconfig.dart';
import 'package:pawpal/pet.dart';
import 'package:pawpal/user.dart';
import 'package:pawpal/petdetailspage.dart';

class PublicPetsPage extends StatefulWidget {
  final User user;
  const PublicPetsPage({super.key, required this.user});

  @override
  State<PublicPetsPage> createState() => _PublicPetsPageState();
}

class _PublicPetsPageState extends State<PublicPetsPage> {
  List<Pet> pets = [];
  String search = "";
  String selectedType = "All";
  List<String> types = ["All", "Cat", "Dog", "Bird", "Rabbit", "Other"];

  @override
  void initState() {
    super.initState();
    loadPets();
  }

  Future<void> loadPets() async {
    String url =
        "${MyConfig.baseUrl}${MyConfig.backend}/load_all_pets.php?search=$search&type=$selectedType";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == 'success') {
        setState(() {
          pets = (jsonResponse['data'] as List)
              .map((e) => Pet.fromJson(e))
              .toList();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adopt a Pet")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: "Search name...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      search = val;
                      loadPets();
                    },
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: selectedType,
                  items: types
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedType = val!);
                    loadPets();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading:
                        (pet.imagePaths != null && pet.imagePaths!.isNotEmpty)
                        ? Image.network(
                            "${MyConfig.baseUrl}${MyConfig.backend}/uploads/pets/${pet.imagePaths![0]}",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.pets, size: 50),
                    title: Text(
                      pet.petName ?? "Unknown",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "${pet.petType} • ${pet.category}\nAge: ${pet.petAge}",
                    ),
                    isThreeLine: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PetDetailsPage(user: widget.user, pet: pet),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
