import 'package:cloud_firestore/cloud_firestore.dart';

class ImagePost {
  final String id; // Ensure this line is added
  final String title;
  List<String> imageUrls;
  final String description;
  final double latitude;
  final double longitude;
  final String tags;

  ImagePost({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.tags,
  });

  factory ImagePost.fromDocument(DocumentSnapshot doc) {
    return ImagePost(
        id: doc.id, // Make sure to extract the document ID here
        title: doc['Title'] ?? '',
        imageUrls: List<String>.from(doc['urls']),
        description: doc['Description'] ?? '',
        latitude: doc['latitude'] ?? 0.0,
        longitude: doc['longitude'] ?? 0.0,
        tags: doc['Title'] ?? '');
  }
}
