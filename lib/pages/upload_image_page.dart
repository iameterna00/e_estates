import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/widgets/location_picker.dart';
import 'package:e_estates/widgets/upload_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;
import 'package:permission_handler/permission_handler.dart';

class ImageUpload extends StatefulWidget {
  const ImageUpload({
    super.key,
    // Removed 'required' to make it truly optional and nullable
  });

  @override
  ImageUploadState createState() => ImageUploadState();
}

class ImageUploadState extends State<ImageUpload> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  List<XFile>? _selectedImages;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<String> tags = ["Rent", "Apartment", "Hotel"];
  String? selectedTag;
  bool highlightedlocationButton = false;
  bool isTagSelectionValid = true;
  bool _locationPicked = false;
  double? latitude;
  double? longitude;
  String? location;
  String? paymentFrequency;
  List<String>? homeAminities;

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
    User? user = FirebaseAuth.instance.currentUser;
    String name = user?.displayName ?? "";
    String profilePicture = user?.photoURL ?? "";
    if (_selectedImages == null ||
        _selectedImages!.isEmpty ||
        !_formKey.currentState!.validate()) {
      return;
    }
    if (selectedTag == null) {
      setState(() {
        isTagSelectionValid = false;
      });

      return;
    }
    if (_locationPicked == false) {
      setState(() {
        highlightedlocationButton = true;
      });

      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
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
    List<String> imageUrls = [];

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
        await uploadTask.whenComplete(() async {});
        String downloadURL = await storageReference.getDownloadURL();
        imageUrls.add(downloadURL);
      } catch (e) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Failed to upload images. Please try again.')),
          );
          return;
        }
      }
    }
    try {
      await FirebaseFirestore.instance.collection('image').add({
        'Title': titleController.text,
        'Description': descriptionController.text,
        'urls': imageUrls, // Save list of image URLs
        'uploadedAt': FieldValue.serverTimestamp(),
        'latitude': latitude,
        'longitude': longitude,
        'Tags': selectedTag != null ? [selectedTag] : [],
        'Price': double.tryParse(priceController.text) ?? 0.0,
        'Location': location,
        'PaymentFrequency': paymentFrequency,
        'HomeAmanities': homeAminities,
        'uploader': {"Name": name, "ProfilePicture": profilePicture}
      });
    } catch (e) {}

    setState(() {
      print("Payment $paymentFrequency");
      _selectedImages = [];
      titleController.clear();
      descriptionController.clear();
      priceController.clear();
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
      appBar: AppBar(
        title: const Text('New Post'),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 65,
        child: ElevatedButton(
          style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)))),
          onPressed: () async {
            await uploadImage(); // Trigger upload process
          },
          child: const Text(
            'Share',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    await requestPermission();
                    await pickImages();
                  },
                  child: Container(
                    height: 300,
                    width: 400,
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        _selectedImages != null && _selectedImages!.isNotEmpty
                            ? PageView.builder(
                                itemCount: _selectedImages!.length,
                                itemBuilder: (context, index) {
                                  return InteractiveViewer(
                                    panEnabled: true,
                                    scaleEnabled: true,
                                    child: Image.file(
                                      File(_selectedImages![index].path),
                                      width: double.infinity,
                                      //  height: double.infinity,
                                    ),
                                  );
                                },
                              )
                            : const Icon(Icons.add_a_photo, size: 80),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: tags.map((tag) {
                      IconData iconData = Icons.error; // Default icon
                      switch (tag) {
                        case "Rent":
                          iconData = Icons.house;
                          break;
                        case "Apartment":
                          iconData = Icons.apartment;
                          break;
                        case "Hotel":
                          iconData = Icons.hotel;
                          break;
                      }

                      bool isSelected = selectedTag == tag;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: !isTagSelectionValid && !isSelected
                            ? BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.2),
                                    spreadRadius: 0.5,
                                    blurRadius: 3,
                                  ),
                                ],
                              )
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: FilterChip(
                              elevation: 0,
                              label: Text(tag),
                              avatar: Icon(iconData, size: 20.0),
                              selected: isSelected,
                              onSelected: (bool selected) {
                                setState(() {
                                  selectedTag = tag;
                                  isTagSelectionValid = true;
                                });
                              },
                              backgroundColor: Colors.transparent,
                              selectedColor: Colors.blue.withOpacity(0.3),
                              shape: isSelected
                                  ? RoundedRectangleBorder(
                                      side: const BorderSide(
                                        color: Colors.blue,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8))
                                  : null),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                UploadWidgets(
                  homeAminities: (newhome) {
                    setState(() {
                      homeAminities = newhome;
                    });
                  },
                  onPaymentFrequencyChanged: (newPaymentFrequency) {
                    setState(() {
                      paymentFrequency = newPaymentFrequency;
                    });
                  },
                  saveMystate: navigateAndReceiveLocation,
                  titleController: titleController,
                  descriptionController: descriptionController,
                  priceController: priceController,
                  highlightLocationButton: highlightedlocationButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> navigateAndReceiveLocation() async {
    FocusNode unfocusNode = FocusNode();
    FocusScope.of(context).requestFocus(unfocusNode);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LocationPickerMap(),
      ),
    );

    if (result != null) {
      print("Selected location: $result");

      setState(() {
        _locationPicked = true;
        latitude = result['latitude'];
        longitude = result['longitude'];
        location = result['Location'];
      });
    }
  }
}
