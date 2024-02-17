import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/service/image_post.dart';

import 'package:flutter/material.dart';

class TopFeed extends StatefulWidget {
  const TopFeed({super.key});

  @override
  State<TopFeed> createState() => _TopFeedState();
}

class _TopFeedState extends State<TopFeed> {
  Future<List<ImagePost>> fetchPost() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('image').get();
    return snapshot.docs.map((doc) => ImagePost.fromDocument(doc)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ImagePost>>(
      future: fetchPost(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const Center(
            child: Text('nothings here'),
          );
        }
        List<ImagePost> posts = snapshot.data!;
        return CarouselSlider(
          options: CarouselOptions(
            aspectRatio: 16 / 10,
            viewportFraction: 0.7,
            enlargeCenterPage: false,
            scrollDirection: Axis.horizontal,
            autoPlay: false,
          ),
          items: posts.map((ImagePost post) {
            return Builder(
              builder: (BuildContext context) {
                return InkWell(
                  onTap: () {},
                  child: Container(
                      //width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(20)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            20), // This ensures the image corners are also rounded.
                        child: Image.network(
                          post.imageUrl,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.height,
                        ),
                      )),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
