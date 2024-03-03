import 'package:cloud_firestore/cloud_firestore.dart';

class ImagePost {
  final String id;
  final String title;
  List<String> imageUrls;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> tags;
  final double price;
  final String location;
  final String? paymentfrequency;
  final List<String>? homeAminities;
  final String uploaderName; // Add this line
  final String uploaderProfilePicture; // Add this line

  ImagePost({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.tags,
    required this.price,
    required this.location,
    this.paymentfrequency,
    this.homeAminities,
    required this.uploaderName,
    required this.uploaderProfilePicture,
  });

  factory ImagePost.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ImagePost(
      id: doc.id,
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
      homeAminities: data.containsKey('HomeAmanities')
          ? List<String>.from(data['HomeAmanities'])
          : null,
      uploaderName: data['uploader']?['Name'],
      uploaderProfilePicture: data['uploader']?['ProfilePicture'],
    );
  }
}
