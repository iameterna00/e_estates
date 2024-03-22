import 'package:e_estates/models/image_post.dart';
import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final postDistanceProvider =
    FutureProvider.family<dynamic, ImagePost>((ref, post) async {
  final locationData = ref.watch(locationNotifierProvider);
  if (locationData != null &&
      locationData.latitude != null &&
      locationData.longitude != null) {
    var result = await ref
        .read(locationNotifierProvider.notifier)
        .calculateDistance(post.latitude, post.longitude);
    if (result is String) {
      // Handle the case where the result is a location name
      // You might want to display this information differently in your UI
    }
    return result;
  }
  return 1.0;
});
