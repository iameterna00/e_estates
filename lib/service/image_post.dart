import 'package:cloud_firestore/cloud_firestore.dart';

class ImagePost {
  final String title;
  final String imageUrl;
  final String description;
  final double latitude;
  final double longitude;

  ImagePost(
      {required this.title,
      required this.imageUrl,
      required this.description,
      required this.latitude,
      required this.longitude});

  factory ImagePost.fromDocument(DocumentSnapshot doc) {
    return ImagePost(
      title: doc['Title'] ?? '',
      imageUrl: doc['url'] ?? '',
      description: doc['Description'] ?? '',
      latitude: doc['latitude'] ?? 0.0,
      longitude: doc['longitude'] ?? 0.0,
    );
  }
}
