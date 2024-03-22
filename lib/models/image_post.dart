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
  final List<String>? ownerPreferences;
  final String uploaderName;
  final String uid;
  final String uploaderProfilePicture;

  bool isLikedByCurrentUser;
  final List<String> likedUsers;

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
      this.paymentfrequency,
      this.homeAminities,
      this.ownerPreferences,
      required this.uploaderName,
      required this.uid,
      required this.uploaderProfilePicture,
      required this.likedUsers,
      required this.isLikedByCurrentUser});

  factory ImagePost.fromDocument(DocumentSnapshot doc, String currentUserId) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    bool isLiked =
        (data['likedUsers'] as List<dynamic>? ?? []).contains(currentUserId);

    return ImagePost(
        id: doc.id,
        title: data['Title'] ?? '',
        imageUrls: List<String>.from(data['urls']),
        description: data['Description'] ?? '',
        latitude: data['latitude'] ?? 0.0,
        longitude: data['longitude'] ?? 0.0,
        tags: List<String>.from(data['Tags'] ?? []),
        price: data['Price']?.toDouble() ?? 0.0,
        location: data['Location'] ?? '',
        paymentfrequency: data['PaymentFrequency'],
        homeAminities: List<String>.from(data['HomeAmanities'] ?? []),
        uploaderName: data['Name'],
        uid: data['UID'],
        uploaderProfilePicture: data['ProfilePicture'],
        ownerPreferences: List<String>.from(data['OwnerPreferences'] ?? []),
        isLikedByCurrentUser: isLiked,
        likedUsers: List<String>.from(data['likedUsers'] ?? []));
  }
}
