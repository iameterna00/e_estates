import 'package:e_estates/service/image_post.dart';
import 'package:e_estates/stateManagement/postdistance_provider.dart';
import 'package:e_estates/stateManagement/top_feed_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PostWithDistance {
  final ImagePost post;
  final double distance;

  PostWithDistance(this.post, this.distance);
}

Future<List<PostWithDistance>> fetchPostsAndDistances(WidgetRef ref) async {
  // Read the AsyncValue from the provider.
  final asyncValue = ref.read(topFeedProvider);

  // Initialize an empty list of PostWithDistance.
  List<PostWithDistance> postsWithDistances = [];

  // Check if the AsyncValue holds data and extract it.
  if (asyncValue is AsyncData<List<ImagePost>>) {
    // Extract the list of posts from the AsyncValue.
    final posts = asyncValue.value;

    // Iterate over the list of posts.
    for (var post in posts) {
      // Calculate the distance for each post.
      final distance = await ref.read(postDistanceProvider(post).future);
      // Add the PostWithDistance to the list.
      postsWithDistances.add(PostWithDistance(post, distance));
    }

    // Sort the list by distance.
    postsWithDistances.sort((a, b) => a.distance.compareTo(b.distance));
  }

  return postsWithDistances;
}
