import 'package:e_estates/service/image_post.dart';
import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postDistanceProvider =
    FutureProvider.family<double, ImagePost>((ref, post) async {
  final locationData = ref.watch(locationNotifierProvider);
  if (locationData != null) {
    return ref
        .read(locationNotifierProvider.notifier)
        .calculateDistance(post.latitude, post.longitude);
  }
  return -1.0; // Or any default value indicating an error or unavailable location
});
