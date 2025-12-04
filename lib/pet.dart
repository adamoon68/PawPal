import 'dart:convert';

class Pet {
  String? petId;
  String? userId;
  String? petName;
  String? petType;
  String? category;
  String? description;
  List<String>? imagePaths;
  String? lat;
  String? lng;
  String? createdAt;

  Pet({
    this.petId,
    this.userId,
    this.petName,
    this.petType,
    this.category,
    this.description,
    this.imagePaths,
    this.lat,
    this.lng,
    this.createdAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    // image_paths stored as JSON string in DB; ensure it's a list
    List<String> images = [];
    if (json['image_paths'] != null) {
      try {
        var ip = json['image_paths'];
        if (ip is String) {
          images = List<String>.from(jsonDecode(ip));
        } else if (ip is List) {
          images = List<String>.from(ip);
        }
      } catch (e) {
        images = [];
      }
    }
    return Pet(
      petId: json['pet_id']?.toString(),
      userId: json['user_id']?.toString(),
      petName: json['pet_name'],
      petType: json['pet_type'],
      category: json['category'],
      description: json['description'],
      imagePaths: images,
      lat: json['lat']?.toString(),
      lng: json['lng']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}
