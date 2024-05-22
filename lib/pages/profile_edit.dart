import 'dart:io';
import 'package:e_estates/service/profile_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_estates/stateManagement/user_uid.dart';
import 'package:image_picker/image_picker.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  String? userProfile;
  String? userName;
  String? userNumber;
  final ImagePicker _picker = ImagePicker();
  TextEditingController numberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String selectedOption = '';

  List<XFile>? _selectedImages;

  @override
  void initState() {
    super.initState();
    initializeUserProfile();
  }

  Future<void> pickImages(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedImages = [pickedImage];
      });
    }
  }

  Future<void> initializeUserProfile() async {
    try {
      userProfile = await getCurrentUserProfile();
      userName = await getCurrentUsername();
      userNumber = await getCurrentUserNumber();

      setState(() {
        if (userName != null) {
          nameController.text = userName!;
        }
        if (userNumber != null) {
          numberController.text = userNumber!;
        }
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  void onOptionSelected(String option) {
    setState(() {
      selectedOption = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    GestureDetector(
                      child: CircleAvatar(
                        radius: 75,
                        backgroundColor: Colors.grey[900],
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (userProfile != null &&
                                userProfile!.isNotEmpty &&
                                (_selectedImages == null ||
                                    _selectedImages!.isEmpty))
                              CircleAvatar(
                                radius: 75,
                                backgroundImage: NetworkImage(userProfile!),
                              ),
                            if (_selectedImages != null &&
                                _selectedImages!.isNotEmpty)
                              CircleAvatar(
                                radius: 75,
                                backgroundImage:
                                    FileImage(File(_selectedImages![0].path)),
                              ),
                            if ((userProfile == null || userProfile!.isEmpty) &&
                                (_selectedImages == null ||
                                    _selectedImages!.isEmpty))
                              const CircleAvatar(
                                radius: 75,
                                child: Icon(
                                  Icons.person,
                                  size: 80,
                                ),
                              ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Color.fromARGB(255, 52, 52, 52),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white, // Plus sign icon color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        await ProfileUpdate.requestPermission();
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
                    ),
                    TextButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.transparent),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Edit Picture",
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text("Name"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: nameController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 52, 52, 52)
                      : Colors.grey[300],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "userName",
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text("I am"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildOptionButton('Broker'),
                  buildOptionButton('House Owner'),
                  buildOptionButton('Student'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text("Number"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+-]')),
                ],
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 52, 52, 52)
                      : Colors.grey[300],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "+977",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildOptionButton(String option) {
    return InkWell(
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () => onOptionSelected(option),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: selectedOption == option
              ? Colors.blue
              : const Color.fromARGB(255, 52, 52, 52),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          option,
          style: const TextStyle(),
        ),
      ),
    );
  }
}
