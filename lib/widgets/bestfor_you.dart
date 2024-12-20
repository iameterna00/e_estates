import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/models/usermodel.dart';
import 'package:e_estates/pages/my_profilepage.dart';
import 'package:e_estates/pages/topfeed_detaipage.dart';
import 'package:e_estates/models/image_post.dart';
import 'package:e_estates/pages/user_profile.dart';
import 'package:e_estates/service/commentmodel.dart';
import 'package:e_estates/service/customtime.dart';
import 'package:e_estates/service/likemodel.dart';
import 'package:e_estates/stateManagement/auth_state_provider.dart';
import 'package:e_estates/stateManagement/fetch_user_uid.dart';
import 'package:e_estates/stateManagement/filterstudent.dart';
import 'package:e_estates/stateManagement/postdistance_provider.dart';
import 'package:e_estates/stateManagement/top_feed_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class BestForYou extends ConsumerWidget {
  final String selectedTag;

  const BestForYou({super.key, required this.selectedTag});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool filterIsStudent = ref.watch(isStudentFilterProvider);
    final postsAsyncValue = ref.watch(topFeedProvider);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: postsAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) {
              // Check for specific network-related error messages
              if (error.toString().contains('Failed host lookup')) {
                return const Center(
                    child: Text('Please check your internet connection.'));
              } else {
                // Log the error or handle other types of errors
                debugPrint(
                    'Unexpected error: $error, Stack trace: $stackTrace');
                return const Center(
                    child: Text(
                        'An unexpected error occurred. Please try again later.'));
              }
            },
            data: (posts) {
              List<ImagePost> filteredPosts = posts;
              if (selectedTag != "All") {
                filteredPosts = posts
                    .where((post) => post.tags.contains(selectedTag))
                    .toList();
              }
              if (filterIsStudent) {
                filteredPosts =
                    filteredPosts.where((post) => post.isStudent).toList();
              }
              if (filteredPosts.isEmpty) {
                return Center(
                  child: Image.asset('assets/icons/empty.png',
                      height: 250, width: 250),
                );
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
                      String distanceDisplay;
                      if (distance is double) {
                        distanceDisplay = '${distance.toStringAsFixed(1)} Km';
                      } else if (distance is String) {
                        distanceDisplay =
                            distance; // If distance is a location name
                      } else {
                        distanceDisplay =
                            'Unknown'; // Fallback for any other cases
                      }
                      return buildPostItem(context, post, ref, distanceDisplay);
                    },
                    loading: () =>
                        buildPostItem(context, post, ref, 'Calculating...'),
                    error: (e, stack) =>
                        buildPostItem(context, post, ref, 'Error!'),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildPostItem(BuildContext context, ImagePost post, WidgetRef ref,
      String distanceDisplay) {
    bool isBottomsheet = true;
    String userUid = post.uid;
    DateTime uploadedAtDateTime;

    if (post.uploadedAt is Timestamp) {
      uploadedAtDateTime = (post.uploadedAt as Timestamp).toDate();
    } else if (post.uploadedAt is DateTime) {
      uploadedAtDateTime = post.uploadedAt;
    } else {
      uploadedAtDateTime = DateTime.now();
    }

    final uploadTimeAgo = customTimeAgo(uploadedAtDateTime);
    return FutureBuilder<UserModel>(
        future: fetchUserModelByUid(post.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          }

          if (snapshot.hasError) {
            return Text('Error loading user data: ${snapshot.error}');
          }

          final userModel = snapshot.data!;

          bool isNavigating = false;

          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 12, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        final user = ref.watch(userProvider)?.uid;
                        String currentUserId = user as String;
                        if (isNavigating) return;
                        isNavigating = true;

                        try {
                          if (userUid == currentUserId) {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const MyProfilePage(),
                            ));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  UserProfilePage(user: userModel),
                            ));
                          }
                        } finally {
                          isNavigating = false;
                        }
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  userModel.photoUrl!.isNotEmpty
                                      ? userModel.photoUrl!
                                      : 'assets/icons/noProfile.png'),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                post.uploaderName,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {},
                    )
                  ],
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.transparent,
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TopFeedDetail(
                            detailpagepost: post,
                            distance: distanceDisplay,
                            postID: post.id,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            post.imageUrls.isNotEmpty
                                ? post.imageUrls[0]
                                : 'assets/icons/noProfile.png',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            height: 350,
                            errorBuilder: (context, error, stackTrace) {
                              // This builder will work when there is an error in loading the image
                              return Image.asset(
                                'assets/icons/noProfile.png', // Fallback asset image
                                fit: BoxFit.cover,
                                width: MediaQuery.of(context).size.width,
                                height: 350,
                              );
                            },
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: distanceDisplay.isNotEmpty
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 1),
                                      Image.asset(
                                        'assets/icons/IC_Location.png',
                                        scale: 1.5,
                                      ),
                                      const SizedBox(width: 1),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        child: Text(distanceDisplay,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 8)),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                        ),
                        Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  uploadTimeAgo,
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            )),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: InkWell(
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.message,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ],
                                ),
                                onTap: () => showCommentsBottomSheet(
                                    context, post.id, isBottomsheet),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          right: 0,
                          child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20),
                                    bottomLeft: Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    child: Row(
                                      children: [
                                        LikeButtonWidget(
                                          postId: post.id,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8, left: 8, top: 8),
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
                        "Rs ${NumberFormat('#,##,###.##', 'en_IN').format(post.price)}/ ${post.paymentfrequency}",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(post.location,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 2.0,
                        runSpacing: 2.0,
                        children: post.tags.map((String tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Text(tag,
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Colors.grey
                                      : Colors.white,
                                  fontSize: 10,
                                )),
                          );
                        }).toList(),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
