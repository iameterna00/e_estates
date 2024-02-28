import 'package:e_estates/pages/topfeed_detaipage.dart';
import 'package:e_estates/service/image_post.dart';

import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:e_estates/stateManagement/postdistance_provider.dart';
import 'package:e_estates/stateManagement/top_feed_provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final distanceProvider =
    FutureProvider.family<double, ImagePost>((ref, post) async {
  final locationNotifier = ref.read(locationNotifierProvider.notifier);
  return await locationNotifier.calculateDistance(
      post.latitude, post.longitude);
});

class BestForYou extends ConsumerWidget {
  final String selectedTag;

  BestForYou({Key? key, required this.selectedTag}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsyncValue = ref.watch(topFeedProvider);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: postsAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Error: $err'),
            data: (posts) {
              List<ImagePost> filteredPosts = posts;
              if (selectedTag != "All") {
                filteredPosts = posts
                    .where((post) => post.tags.contains(selectedTag))
                    .toList();
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  final post = filteredPosts[index];

                  final distanceAsyncValue =
                      ref.watch(postDistanceProvider(post));
                  return distanceAsyncValue.when(
                    data: (distance) {
                      String distanceDisplay =
                          '${distance.toStringAsFixed(1)} Km';
                      return buildPostItem(context, post, distanceDisplay);
                    },
                    loading: () =>
                        buildPostItem(context, post, 'Calculating...'),
                    error: (e, stack) => buildPostItem(context, post, 'Error!'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildPostItem(
      BuildContext context, ImagePost post, String distanceDisplay) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 0, bottom: 10),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TopFeedDetail(
                detailpagepost: post,
                distance: distanceDisplay,
              ),
            ),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                color: Colors.transparent,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  post.imageUrls[0],
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Rs ${NumberFormat('#,##,###.##', 'en_IN').format(post.price)}",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      distanceDisplay,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      post.tags.join(),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
