import 'package:cloud_firestore/cloud_firestore.dart';

class ImagePost {
  final String id; // Ensure this line is added
  final String title;
  List<String> imageUrls;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> tags;
  final double price;
  final String location;
  final String? paymentfrequency;

  ImagePost(
      {required this.id,
      required this.title,
      required this.imageUrls,
      required this.description,
      required this.latitude,
      required this.longitude,
      required this.tags,
      required this.price,
      required this.location,
      this.paymentfrequency});

  factory ImagePost.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ImagePost(
      id: doc.id, // Make sure to extract the document ID here
      title: doc['Title'] ?? '',
      imageUrls: List<String>.from(doc['urls']),
      description: doc['Description'] ?? '',
      latitude: doc['latitude'] ?? 0.0,
      longitude: doc['longitude'] ?? 0.0,
      tags: List<String>.from(doc['Tags'] ?? []),
      price: doc['Price']?.toDouble() ?? 0.0,
      location: doc['Location'] ?? '',
      paymentfrequency: data.containsKey('PaymentFrequency')
          ? data['PaymentFrequency']
          : 'Monthly',
    );
  }
}
