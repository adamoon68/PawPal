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

  // load pets from server
  Future<void> loadPets() async {
    final url = Uri.parse(
      '${MyConfig.baseUrl}${MyConfig.backend}/get_my_pets.php',
    );

    http.post(url, body: {'user_id': widget.user.userId ?? '0'}).then((
      response,
    ) {
      if (response.statusCode == 200) {
        var jsonResponse = response.body;
        var resarray = jsonDecode(jsonResponse);

        if (resarray['success'] == true) {
          var data = resarray['data'] as List;
          pets = data.map((e) => Pet.fromJson(e)).toList();

          if (pets.isEmpty) {
            status = 'No submissions yet.';
          }
        } else {
          status = resarray['message'] ?? 'No submissions yet.';
          pets = [];
        }
      } else {
        status = 'Server error ${response.statusCode}';
      }

      if (mounted) {
        setState(() {});
      }
    });
  }

  // confirm delete dialog
  void _confirmDelete(String petId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Entry"),
        content: const Text("Are you sure you want to delete this pet?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePet(petId);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // delete pet from server
  Future<void> _deletePet(String petId) async {
    final url = Uri.parse(
      '${MyConfig.baseUrl}${MyConfig.backend}/get_my_pets.php',
    );
    try {
      final resp = await http
          .post(url, body: {'pet_id': petId, 'operation': 'delete'})
          .timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body);
        if (json['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pet deleted successfully"),
              backgroundColor: Colors.green,
            ),
          );
          loadPets();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(json['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error deleting pet"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // show image gallery dialog
  void _showImageGallery(Pet pet) {
    if (pet.imagePaths == null || pet.imagePaths!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No images available.")));
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        final PageController pageController = PageController();
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          child: SizedBox(
            height: 500,
            width: double.infinity,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Expanded(
                          child: PageView.builder(
                            controller: pageController,
                            itemCount: pet.imagePaths!.length,
                            itemBuilder: (context, index) {
                              String fullUrl =
                                  "${MyConfig.baseUrl}${MyConfig.backend}/uploads/pets/${pet.imagePaths![index]}";
                              return Image.network(
                                fullUrl,
                                fit: BoxFit.contain,
                                loadingBuilder: (ctx, child, p) => (p == null)
                                    ? child
                                    : const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                errorBuilder: (ctx, error, stack) =>
                                    const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 50,
                                        color: Colors.grey,
                                      ),
                                    ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[200],
                          width: double.infinity,
                          child: Text(
                            "Swipe for more photos (${pet.imagePaths!.length})",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  elevation: 3,
                  child: ListTile(
                    onTap: () => _showImageGallery(p),

                    leading: thumb == null
                        ? const SizedBox(
                            width: 60,
                            height: 60,
                            child: Icon(Icons.pets, color: Colors.grey),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              thumb,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),

                    title: Text(
                      p.petName ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Type and Category
                        Text(
                          '${p.petType} • ${p.category}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          (p.description ?? '').length > 60
                              ? '${p.description!.substring(0, 60)}...'
                              : p.description ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),

                        if (p.imagePaths != null && p.imagePaths!.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              "+ ${p.imagePaths!.length - 1} more photos",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.blue,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ),
                    isThreeLine: true,

                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        if (p.petId != null) _confirmDelete(p.petId!);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
