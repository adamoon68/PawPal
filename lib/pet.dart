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
    List<String> images = [];

    if (json['image_paths'] != null) {
      try {
        var ip = json['image_paths'];
      
        if (ip is String) {
          
          if (ip.startsWith('[') && ip.endsWith(']')) {
             images = List<String>.from(jsonDecode(ip));
          } else {
         
             images = [ip]; 
          }
        } 
       
        else if (ip is List) {
          images = List<String>.from(ip.map((e) => e.toString()));
        }
      } catch (e) {
        print("Error parsing images: $e");
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

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pet_id'] = petId;
    data['user_id'] = userId;
    data['pet_name'] = petName;
    data['pet_type'] = petType;
    data['category'] = category;
    data['description'] = description;
    
    data['image_paths'] = imagePaths; 
    
    data['lat'] = lat;
    data['lng'] = lng;
    data['created_at'] = createdAt;
    return data;
  }
}