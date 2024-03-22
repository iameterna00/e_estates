import 'package:e_estates/pages/topfeed_detaipage.dart';
import 'package:e_estates/models/image_post.dart';

import 'package:e_estates/stateManagement/postdistance_provider.dart';
import 'package:e_estates/stateManagement/top_feed_provider.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopFeed extends ConsumerWidget {
  final String selectedTag;

  const TopFeed({super.key, required this.selectedTag});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsyncValue = ref.watch(topFeedProvider);

    return Container(
      child: postsAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Text('Error: $err'),
        data: (posts) {
          List<ImagePost> filteredPosts = posts;
          if (selectedTag != "All") {
            filteredPosts =
                posts.where((post) => post.tags.contains(selectedTag)).toList();
          }

          if (filteredPosts.isEmpty) {
            return Center(
              child: Image.asset('assets/icons/empty.png',
                  height: 250, width: 250),
            );
          }

          bool hasValidPost = false;

          List<Widget> postWidgets =
              List.generate(filteredPosts.length, (index) {
            final post = filteredPosts[index];
            return ref.watch(postDistanceProvider(post)).when(
                  data: (distance) {
                    if (distance is double && distance <= 10.0) {
                      hasValidPost = true;
                      String distanceDisplay =
                          '${distance.toStringAsFixed(1)} Km';
                      return buildPostItem(context, post, distanceDisplay);
                    } else {
                      return Container();
                    }
                  },
                  loading: () => buildPostItem(context, post, 'Calculating...'),
                  error: (e, stack) => buildPostItem(context, post, 'Error!'),
                );
          });

          if (!hasValidPost) {
            return Center(
              child: Image.asset('assets/icons/empty.png',
                  height: 250, width: 250),
            );
          } else {
            return SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: postWidgets,
              ),
            );
          }
        },
      ),
    );
  }

  Widget buildPostItem(
      BuildContext context, ImagePost post, String distanceDisplay) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10,
        right: 0,
      ),
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
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Colors.transparent,
          ),
          child: Stack(
            children: [
              AspectRatio(
                aspectRatio: 14 / 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Image.network(
                        post.imageUrls[0],
                        fit: BoxFit.cover,
                        width: double
                            .infinity, // Ensure the image covers the full width
                        height: double
                            .infinity, // Ensure the image covers the full height
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 100, // Adjust the height as needed
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                right: 10,
                child: Text(
                  post.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              /*  Positioned(
                top: 10,
                right: 10,
                child: RatingBarIndicator(
                  rating: 3, // Assuming a static rating for example
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: Colors.amber),
                  itemCount: 5,
                  itemSize: 18.0,
                ),
              ), */
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                          'assets/icons/IC_Location.png'), // Ensure this asset exists
                      const SizedBox(width: 4),
                      Text(distanceDisplay,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
