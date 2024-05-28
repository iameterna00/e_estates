import 'dart:io';
import 'package:e_estates/service/profile_update.dart';
import 'package:e_estates/stateManagement/user_uid.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

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
  bool indicator = false;
  bool isNumberFilled = false;
  bool _isOTPSent = false;
  String? _verificationId;
  final _auth = FirebaseAuth.instance;
  final _codeController = TextEditingController();
  bool isverified = false;
  bool _isLoading = false;
  List<XFile>? _selectedImages;
  String? _phoneNumber;

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
          await _auth.signInWithCredential(credential);
          setState(() {
            _isOTPSent = true;
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {});
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOTPSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      // Handle error (e.g., show a message to the user)
    }
  }

  Future<void> _signInWithPhoneNumber() async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text,
      );

      // Sign in with the credential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      // Handle successful sign-in
      User? user = userCredential.user;
      if (user != null) {
        await ProfileUpdate.updateUserPhoneNumber(user.uid, user.phoneNumber!);
        print(
            'Signed in successfully and phone number updated: ${user.phoneNumber}');
        setState(() {
          _isLoading == false;
          _isOTPSent == false;
          isverified = true;
        });
      }
    } catch (e) {
      // Handle error
      print('Failed to sign in: $e');
    }
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
        isNumberFilled = false; // Reset when text is empty
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
                                  color: Colors.white, // Plus sign icon color
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        // Your image picking logic here
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
                  LengthLimitingTextInputFormatter(10),
                ],
                onChanged: (value) {
                  _phoneNumber = value;
                },
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
                _isOTPSent == false)
              Center(
                child: ElevatedButton(
                    style: const ButtonStyle(
                        elevation: MaterialStatePropertyAll(0),
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.transparent)),
                    onPressed: () {
                      _verifyPhoneNumber();
                      print(numberController.text);
                    },
                    child: const Text(
                      "Tap To Verify",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                    )),
              ),
            if (_isOTPSent)
              Column(
                children: [
                  const Text("Enter Otp"),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      child: PinCodeTextField(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        appContext: context,
                        length: 6,
                        keyboardType: TextInputType.number,
                        obscureText: false,
                        animationType: AnimationType.none,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(5),
                          fieldHeight: 40,
                          fieldWidth: 40,
                          activeColor: Colors.blue,
                          inactiveColor: Colors.grey,
                          selectedColor: Colors.grey,
                        ),
                        controller: _codeController,
                        onCompleted: (v) {
                          _signInWithPhoneNumber();
                        },
                        onChanged: (value) {},
                      )),
                ],
              ),
            if (isverified)
              const Center(
                child: Text('You are verified'),
              ),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.black)),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                if (_selectedImages != null &&
                                    _selectedImages!.isNotEmpty) {
                                  String imageUrl =
                                      await ProfileUpdate.uploadImage(
                                          File(_selectedImages![0].path),
                                          _auth.currentUser!.uid);
                                  await ProfileUpdate.updateUserProfileUrl(
                                      _auth.currentUser!.uid, imageUrl);
                                }

                                setState(() {
                                  _isLoading = false;
                                });
                              },
                        child: const Center(
                          child: Text(
                            'Done',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
