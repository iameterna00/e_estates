import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';

class ImageUpload extends StatefulWidget {
  const ImageUpload({super.key});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<XFile>? _selectedImages;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> pickImages() async {
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    if (pickedImages.isNotEmpty) {
      setState(() {
        _selectedImages = pickedImages;
      });
    }
  }

  Future<void> uploadImage() async {
    if (_selectedImages == null ||
        _selectedImages!.isEmpty ||
        !_formKey.currentState!.validate()) {
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return const AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(child: CircularProgressIndicator()),
                Text('Uploading, please wait...'),
              ],
            ),
          ),
        );
      },
    );

    for (XFile xFile in _selectedImages!) {
      final File originalFile = File(xFile.path);

      // Compress the image
      final File compressedFile = await compressedImage(
          originalFile); // Note: This method now does not return null, so no need to check for null.

      String filename = Path.basename(compressedFile.path);
      Reference storageReference =
          FirebaseStorage.instance.ref('uploads/$filename');
      try {
        // Start upload
        UploadTask uploadTask = storageReference.putFile(compressedFile);

        // Await for the upload task
        await uploadTask;
        // It's better to use await uploadTask.then() if you need to confirm the task's success
        String downloadURL = await storageReference.getDownloadURL();

        // Save URL and other info in Firebase
        await FirebaseFirestore.instance.collection('image').add({
          'Title': _titleController.text,
          'Description': _descriptionController.text,
          'url': downloadURL,
          'uploadedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        Navigator.of(context)
            .pop(); // Dismiss the loading dialog in case of an error
        print(e);
        return; // Exit the function if an error occurs
      }
    }

    setState(() {
      _selectedImages = [];
      _titleController.clear();
      _descriptionController.clear();
    });
    Navigator.of(context)
        .pop(); // Dismiss the loading dialog after upload is complete
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Images uploaded successfully!')));
  }

  Future<File> compressedImage(File file) async {
    final imglib.Image? image = imglib.decodeImage(await file.readAsBytes());
    if (image == null) throw Exception('Failed to decode image');

    final imglib.Image resizedImage = imglib.copyResize(image, width: 800);

    final directory = await getTemporaryDirectory();
    final String targetPath =
        Path.join(directory.path, 'compressed_${Path.basename(file.path)}');

    // Save the resized image to the target path as a JPEG.
    final File compressedFile = File(targetPath)
      ..writeAsBytesSync(imglib.encodeJpg(resizedImage,
          quality: 85)); // Adjust quality as needed.

    return compressedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          // Added to accommodate scrolling
          padding: const EdgeInsets.all(15.0),
          child: Form(
            // Wrap with Form widget
            key: _formKey,
            child: Column(
              children: [
                InkWell(
                  // Use InkWell to make the container clickable
                  onTap: () async {
                    await requestPermission();
                    await pickImages(); // Adjust to only pick images
                  },
                  child: Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(8)),
                    child:
                        _selectedImages != null && _selectedImages!.isNotEmpty
                            ? ListView.builder(
                                // Use ListView.builder to show all selected images
                                scrollDirection: Axis.horizontal,
                                itemCount: _selectedImages!.length,
                                itemBuilder: (context, index) {
                                  return Image.file(
                                    File(_selectedImages![index].path),
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : const Icon(Icons.add_a_photo, size: 80),
                  ),
                ),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    await uploadImage(); // Trigger upload process
                  },
                  child: const Text('Upload'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
