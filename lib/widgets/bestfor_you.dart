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
    DateTime uploadedAtDateTime;

    if (post.uploadedAt is Timestamp) {
      uploadedAtDateTime = (post.uploadedAt as Timestamp).toDate();
    } else if (post.uploadedAt is DateTime) {
      uploadedAtDateTime = post.uploadedAt;
    } else {
      uploadedAtDateTime = DateTime.now();
    }

    final uploadTimeAgo = customTimeAgo(uploadedAtDateTime);

    bool isNavigating = false;
    final user = ref.watch(userProvider).uid;
    bool isLikedLocally = post.isLikedByCurrentUser;

    int likesCount = post.likedUsers.length;
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
                  String userUid = post.uid;
                  String currentUserId = user as String;
                  if (isNavigating) return;
                  isNavigating = true;

                  try {
                    if (userUid == currentUserId) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MyProfilePage(),
                      ));
                    } else {
                      UserModel userModel = await fetchUserModelByUid(userUid);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => UserProfilePage(user: userModel),
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
                          backgroundImage: post
                                  .uploaderProfilePicture.isNotEmpty
                              ? NetworkImage(post.uploaderProfilePicture)
                              : const AssetImage('assets/icons/noProfile.png')
                                  as ImageProvider),
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
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      post.imageUrls[0],
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width,
                      height: 350,
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
                                          color: Colors.white, fontSize: 8)),
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
                          onTap: () =>
                              showCommentsBottomSheet(context, post.id),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 0,
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
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
                                    onLikePressed: () {
                                      setState(() {
                                        isLikedLocally = !isLikedLocally;

                                        if (isLikedLocally) {
                                          likesCount++;
                                        } else {
                                          likesCount--;
                                        }
                                      });
                                      toggleLikeStatus(post, ref)
                                          .then((newIsLiked) {});
                                    },
                                    isLiked: isLikedLocally,
                                    likesCount: likesCount,
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
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Colors.black,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(tag,
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
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
  }
}
