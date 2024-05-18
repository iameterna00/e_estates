import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () async {
                await requestPermission();
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: const Text('Select from Gallery'),
                            onTap: () async {
                              Navigator.pop(context);
                              await pickImages(ImageSource.gallery);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: const Text('Capture with Camera'),
                            onTap: () async {
                              Navigator.pop(context);
                              await pickImages(ImageSource.camera);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Center(
                child: CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.blue,
                  backgroundImage:
                      _selectedImages != null && _selectedImages!.isNotEmpty
                          ? FileImage(File(_selectedImages![0].path))
                          : null,
                  child: _selectedImages == null || _selectedImages!.isEmpty
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 80,
                          color: Colors.black,
                        )
                      : null,
                ),
              ),
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              setState(() {
                                _isLoading = true;
                              });
                              if (_selectedImages != null &&
                                  _selectedImages!.isNotEmpty) {
                                String imageUrl = await uploadImage(
                                    File(_selectedImages![0].path),
                                    _auth.currentUser!.uid);
                                await updateUserProfileUrl(
                                    _auth.currentUser!.uid, imageUrl);
                                Navigator.of(context)
                                    .pushReplacementNamed('/homepage');
                              }
                              setState(() {
                                _isLoading = false;
                              });
                            },
                      child: const Text('Upload Profile Picture'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<String> uploadImage(File imageFile, String uid) async {
    Reference ref =
        FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');
    UploadTask uploadTask = ref.putFile(imageFile);
    await uploadTask;
    String imageUrl = await ref.getDownloadURL();
    return imageUrl;
  }

  Future<void> updateUserProfileUrl(String uid, String imageUrl) async {
    DocumentReference userDoc =
        FirebaseFirestore.instance.collection('users').doc(uid);
    await userDoc.update({'profileUrl': imageUrl});
  }

  Future<void> pickImages(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedImages = [pickedImage];
      });
    }
  }

  Future<void> requestPermission() async {
    var status = await Permission.photos.status;
    if (!status.isGranted) {
      await Permission.photos.request();
    }
  }
}
