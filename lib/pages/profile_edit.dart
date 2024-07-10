import 'dart:io';
import 'package:e_estates/service/profile_update.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({
    super.key,
    required this.userName,
    required this.getCurrentUserProfile,
    required this.number,
    required this.iAm,
  });
  final String userName;
  final String getCurrentUserProfile;
  final String number;
  final String iAm;

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
  String? selectedOption = '';
  bool indicator = false;
  bool isNumberFilled = false;
  bool _isOTPSent = false;
  String? _verificationId;
  final _auth = FirebaseAuth.instance;
  final _codeController = TextEditingController();
  bool isverified = false;
  bool _isLoading = false;
  List<XFile>? _selectedImages;

  @override
  void initState() {
    super.initState();
    initializeUserProfile();
    numberController.addListener(_updateIndicatorAndCheckNumber);
  }

  @override
  void dispose() {
    numberController.removeListener(_updateIndicatorAndCheckNumber);
    numberController.dispose();
    nameController.dispose();
    super.dispose();
  }

  void _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+977${numberController.text}',
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _updatePhoneNumberInFirestore();
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
          });
          print('Verification failed: $e');
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOTPSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error verifying phone number: $e');
    }
  }

  Future<void> _verifyOTP() async {
    try {
      PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );

      await _updatePhoneNumberInFirestore();
    } catch (e) {
      setState(() {
        _isLoading = false;
        isverified = true;
        userNumber = numberController.text;
      });
      print('Failed to verify OTP: $e');
    }
  }

  Future<void> _updatePhoneNumberInFirestore() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;

        await ProfileUpdate.updateUserPhoneNumber(
            userId, numberController.text);
        print('Phone number updated: +977${numberController.text}');

        setState(() {
          _isLoading = false;
          _isOTPSent = true;
          isverified = true;
        });
      }
    } catch (e) {
      print('Error updating phone number in Firestore: $e');
    }
  }

  Future<void> pickImages() async {
    final List<XFile> pickedImages = await _picker.pickMultiImage();
    List<XFile> croppedFiles = [];

    for (var image in pickedImages) {
      final croppedImage = await ImageCropper().cropImage(
          sourcePath: image.path,
          aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 16),
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

  Future<void> showImagePicker(BuildContext context) async {
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
                  Navigator.pop(context); // Close the modal bottom sheet
                  await pickImages();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Capture with Camera'),
                onTap: () async {
                  Navigator.pop(context); // Close the modal bottom sheet
                  await captureImage();
                },
              ),
            ],
          ),
        );
      },
    );
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

  Future<void> initializeUserProfile() async {
    try {
      userProfile = widget.getCurrentUserProfile;
      userName = widget.userName;
      userNumber = widget.number;
      selectedOption = widget.iAm;

      setState(() {
        if (userName != null) {
          nameController.text = userName!;
        }
        if (userNumber != null) {
          numberController.text = userNumber!;
        }
        if (userNumber == null || userNumber!.isEmpty) {
          indicator = true;
        } else {
          indicator = false;
        }
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  void _updateIndicatorAndCheckNumber() {
    setState(() {
      if (numberController.text.isEmpty) {
        indicator = true;
        isNumberFilled = false;
      } else {
        indicator = false;
        if (numberController.text.length == 10) {
          isNumberFilled = true;
        } else {
          isNumberFilled = false;
        }
      }
    });
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
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () => showImagePicker(context),
                    ),
                    TextButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.transparent),
                      ),
                      onPressed: () => showImagePicker(context),
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
                onChanged: (value) {
                  userName = value;
                },
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
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (value) {},
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                    prefixIcon: Image.asset(
                      'assets/icons/nepalflag.png',
                      scale: 20,
                    ),
                    fillColor: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 52, 52, 52)
                        : Colors.grey[300],
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    prefix: const Text('+977'),
                    suffixIcon: indicator ? const Icon(Icons.warning) : null),
              ),
            ),
            if (isNumberFilled &&
                numberController.text != userNumber &&
                !_isOTPSent)
              Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        style: const ButtonStyle(
                            elevation: MaterialStatePropertyAll(0),
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.transparent)),
                        onPressed: _isLoading
                            ? null
                            : () {
                                _verifyPhoneNumber();
                                FocusScope.of(context).unfocus();
                              },
                        child: const Text(
                          "Send OTP",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        )),
              ),
            if (_isOTPSent)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _codeController,
                  onChanged: (value) {},
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                  ),
                  onCompleted: (value) {
                    _verifyOTP();
                  },
                ),
              ),
            if (isverified)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Phone number verified successfully!',
                  ),
                ),
              ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton(
                  style: const ButtonStyle(
                      elevation: MaterialStatePropertyAll(0),
                      backgroundColor: MaterialStatePropertyAll(Colors.black)),
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() {
                            _isLoading = true;
                          });
                          if (_selectedImages != null &&
                              _selectedImages!.isNotEmpty) {
                            String imageUrl = await ProfileUpdate.uploadImage(
                                File(_selectedImages![0].path),
                                _auth.currentUser!.uid);
                            await ProfileUpdate.updateUserProfileUrl(
                                _auth.currentUser!.uid, imageUrl);
                          }
                          if (userName != null && userName!.isNotEmpty) {
                            await ProfileUpdate.updateName(
                                _auth.currentUser!.uid, userName!);
                          }
                          if (selectedOption != null &&
                              selectedOption!.isNotEmpty) {
                            await ProfileUpdate.iAM(
                                _auth.currentUser!.uid, selectedOption!);
                          }

                          setState(() {
                            _isLoading = false;
                          });

                          Navigator.pop(context);
                        },
                  child: const Center(
                    child: Text(
                      'Done',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
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
