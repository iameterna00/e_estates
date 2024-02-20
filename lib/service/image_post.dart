import 'package:cloud_firestore/cloud_firestore.dart';

class ImagePost {
  final String title;
  final String imageUrl;
  final String description;
  // Add fields for price and location later
  // final double price;
  // final String location;

  ImagePost(
      {required this.title, required this.imageUrl, required this.description});

  factory ImagePost.fromDocument(DocumentSnapshot doc) {
    return ImagePost(
      title: doc['Title'] ?? '',
      imageUrl: doc['url'] ?? '',
      description: doc['Description'] ?? '',
      // Add initialization for price and location later
      // price: doc['price'],
      // location: doc['location'],
    );
  }
}
