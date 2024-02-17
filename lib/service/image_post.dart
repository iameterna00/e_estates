import 'package:cloud_firestore/cloud_firestore.dart';

class ImagePost {
  final String title;
  final String imageUrl;
  // Add fields for price and location later
  // final double price;
  // final String location;

  ImagePost({required this.title, required this.imageUrl});

  factory ImagePost.fromDocument(DocumentSnapshot doc) {
    return ImagePost(
      title: doc['Title'] ?? '',
      imageUrl: doc['url'] ?? '',
      // Add initialization for price and location later
      // price: doc['price'],
      // location: doc['location'],
    );
  }
}
