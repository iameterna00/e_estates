import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class PostFunctions {
  static Future<void> deletePost(BuildContext context, String postId) async {
    try {
      DocumentSnapshot postDocument = await FirebaseFirestore.instance
          .collection('image')
          .doc(postId)
          .get();
      List<dynamic> imageUrls = postDocument.get('urls') as List<dynamic>;
      FirebaseStorage storage = FirebaseStorage.instance;

      for (String url in imageUrls) {
        String filePath = url.replaceAll(
            RegExp(
                r'https://firebasestorage.googleapis.com/v0/b/[a-z0-9-]+.appspot.com/o/'),
            '');
        filePath = Uri.decodeFull(filePath.split('?').first);
        await storage.ref(filePath).delete();
      }

      await FirebaseFirestore.instance.collection('image').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post deleted successfully.")));
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error deleting post: $error")));
    }
  }
}
