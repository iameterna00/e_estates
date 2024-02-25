import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/service/image_post.dart';

Future<List<ImagePost>> fetchPostsByTag(String tag) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('posts')
      .where('Tags', arrayContains: tag)
      .get();

  List<ImagePost> posts =
      snapshot.docs.map((doc) => ImagePost.fromDocument(doc)).toList();
  return posts;
}
