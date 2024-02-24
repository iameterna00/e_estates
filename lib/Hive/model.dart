import 'package:hive/hive.dart';
part 'model.g.dart';

@HiveType(typeId: 1) // Unique typeId for Hive
class ImagePost extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String imageUrl;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final double latitude;
  @HiveField(4)
  final double longitude;
  @HiveField(5)
  final double distance;

  ImagePost({
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.latitude,
    required this.longitude,
    this.distance = 0.0,
  });
}
