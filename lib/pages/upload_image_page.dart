import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_estates/widgets/location_picker.dart';
import 'package:e_estates/widgets/upload_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class ImageUpload extends StatefulWidget {
  const ImageUpload({
    super.key,
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
  List<String> tags = ["Rent", "Apartment", "Hostel"];
  String? selectedTag;
  bool highlightedlocationButton = false;
  bool highlightedAmanitiesButton = false;
  bool highlightedPrefrencesButton = false;
  bool isStudent = false;
  bool checkedlocationButton = false;
  bool isTagSelectionValid = true;
  bool _locationPicked = false;
  bool _amanitiesPicked = false;
  bool _prefrencesPicked = false;
  double? latitude;
  double? longitude;
  String? location;
  String? college;
  String? courses;
  String? paymentFrequency;
  List<String>? homeAminities;
  List<String>? tenentPreferences;

  void handleStudentStatusChange(bool isStudent) {
    setState(() {
      this.isStudent = isStudent;
      print("Student status updated to: $isStudent");
    });
  }

  void takecollege(String? college) {
    setState(() {
      this.college = college;

      print("Student college updated to: $college");
    });
  }

  void takecourses(String? courses) {
    setState(() {
      this.courses = courses;
      print("Student courses updated to: $courses");
    });
  }

  Future<void> requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> pickImages() async {
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    List<XFile> croppedFiles = [];

    for (var image in pickedImages) {
      final croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              toolbarWidgetColor:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
              activeControlsWidgetColor: Colors.grey,
              statusBarColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              dimmedLayerColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black
                  : Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio16x9,
              lockAspectRatio: true,
            ),
          ]);
      if (croppedImage != null) {
        croppedFiles.add(XFile(croppedImage.path));
      }
    }

    if (croppedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = croppedFiles;
      });
    }
  }

  Future<void> captureImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.camera);
    List<XFile> croppedFiles = [];

    if (pickedImage != null) {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            toolbarWidgetColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
            activeControlsWidgetColor: Colors.grey,
            statusBarColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            dimmedLayerColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.black
                : Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true,
          ),
        ],
      );

      if (croppedImage != null) {
        croppedFiles.add(XFile(croppedImage.path));
      }
    }

    if (croppedFiles.isNotEmpty) {
      setState(() {
        _selectedImages = croppedFiles;
      });
    }
  }

  Future<void> uploadImage() async {
    User? user = FirebaseAuth.instance.currentUser;
    String name = user?.displayName ?? "";
    String profilePicture = user?.photoURL ?? "";
    String uid = user!.uid;
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
    if (_amanitiesPicked == false) {
      setState(() {
        highlightedAmanitiesButton = true;
      });

      return;
    }
    if (_prefrencesPicked == false) {
      setState(() {
        highlightedPrefrencesButton = true;
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

      String filename = path.basename(compressedFile.path);
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
      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('image').add({
        'Title': titleController.text,
        'Description': descriptionController.text,
        'urls': imageUrls,
        'uploadedAt': FieldValue.serverTimestamp(),
        'latitude': latitude,
        'longitude': longitude,
        'Tags': selectedTag != null ? [selectedTag] : [],
        'Price': double.tryParse(priceController.text) ?? 0.0,
        'Location': location,
        'PaymentFrequency': paymentFrequency,
        'HomeAmanities': homeAminities,
        'OwnerPreferences': tenentPreferences,
        "Name": name,
        "UID": uid,
        "ProfilePicture": profilePicture,
        'likedUsers': [],
        'IsStudent': isStudent,
        'College': college,
        'Courses': courses
      });
      String postId = docRef.id;
      await docRef.update({'postId': postId});
    } catch (e) {}

    setState(() {
      _selectedImages = [];
      titleController.clear();
      descriptionController.clear();
      priceController.clear();
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Images uploaded successfully!')));
  }

  Future<File> compressedImage(File file) async {
    final imglib.Image? image = imglib.decodeImage(await file.readAsBytes());
    if (image == null) throw Exception('Failed to decode image');

    final imglib.Image resizedImage = imglib.copyResize(image, width: 800);

    final directory = await getTemporaryDirectory();
    final String targetPath =
        path.join(directory.path, 'compressed_${path.basename(file.path)}');

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
                                  Navigator.pop(
                                      context); // Close the modal bottom sheet
                                  await pickImages();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Capture with Camera'),
                                onTap: () async {
                                  Navigator.pop(
                                      context); // Close the modal bottom sheet
                                  await captureImage();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
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
                      IconData iconData = Icons.error;
                      switch (tag) {
                        case "Rent":
                          iconData = Icons.house;

                          break;
                        case "Apartment":
                          iconData = Icons.apartment;
                          break;
                        case "Hostel":
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
                                    color: Colors.red.withOpacity(0.5),
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
                              backgroundColor: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.black
                                  : Colors.white,
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
                        _amanitiesPicked = true;
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
                    checkedLocationButton: checkedlocationButton,
                    highlightedAmanitiesButton: highlightedAmanitiesButton,
                    tenentPreferences: (tenants) {
                      tenentPreferences = tenants;
                      _prefrencesPicked = true;
                    },
                    highlightedPrefrencesButton: highlightedPrefrencesButton,
                    onIsStudentChanged: handleStudentStatusChange,
                    college: takecollege,
                    courses: takecourses),
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
      setState(() {
        checkedlocationButton = true;
        _locationPicked = true;
        latitude = result['latitude'];
        longitude = result['longitude'];
        location = result['Location'];
      });
    }
  }
}
