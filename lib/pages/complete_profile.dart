import 'dart:io';
import 'package:e_estates/service/profile_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CompleteProfile extends StatefulWidget {
  const CompleteProfile({super.key});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  final ImagePicker _picker = ImagePicker();
  List<XFile>? _selectedImages;
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _verificationId;
  bool _isOTPSent = false;
  String? _phoneNumber;
  bool _isVerifying = false;

  void _verifyPhoneNumber() async {
    setState(() {
      _isVerifying = true; // Show progress indicator
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+977${_phoneController.text}',
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          setState(() {
            _isOTPSent = true;
            _isVerifying = false; // Hide progress indicator
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isVerifying = false; // Hide progress indicator
          });
          // Handle error (e.g., show a message to the user)
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isOTPSent = true;
            _isVerifying = false; // Hide progress indicator
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isVerifying = false; // Hide progress indicator
          });
        },
      );
    } catch (e) {
      setState(() {
        _isVerifying = false; // Hide progress indicator
      });
      // Handle error (e.g., show a message to the user)
    }
  }

  Future<void> _signInWithPhoneNumber() async {
    PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _codeController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Complete Profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: InkWell(
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
                child: Center(
                  child: CircleAvatar(
                    radius: 75,
                    backgroundColor: Colors.grey[900],
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_selectedImages == null || _selectedImages!.isEmpty)
                          const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.blue,
                          ),
                        if (_selectedImages != null &&
                            _selectedImages!.isNotEmpty)
                          CircleAvatar(
                            radius: 75,
                            backgroundImage:
                                FileImage(File(_selectedImages![0].path)),
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
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                  child: Text(
                "Upload profile picture",
                style: TextStyle(color: Colors.grey),
              )),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10, left: 14, right: 12),
              child: Text("Number"),
            ),
            if (!_isOTPSent)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly, // allow only digits
                    LengthLimitingTextInputFormatter(10), // limit to 10 digits
                  ],
                  onChanged: (value) {
                    _phoneNumber = value; // Capture phone number value
                  },
                  decoration: InputDecoration(
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 52, 52, 52)
                          : Colors.grey[300],
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: Image.asset(
                        'assets/icons/nepalflag.png',
                        scale: 20,
                      ),
                      prefix: const Text('+977'), // country code
                      hintText: '   Enter your phone number'),
                ),
              ),
            Center(
              child: _isVerifying // Show progress indicator if verifying
                  ? const CircularProgressIndicator()
                  : TextButton(
                      style: const ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.transparent)),
                      onPressed: _verifyPhoneNumber,
                      child: const Text("Generate OTP"),
                    ),
            ),
            const Divider(),
            const SizedBox(
              height: 10,
            ),
            if (_isOTPSent)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
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
                  onCompleted: (v) {},
                  onChanged: (value) {},
                ),
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
                                if (_phoneNumber != null) {
                                  // Update user's phone number if available
                                  await ProfileUpdate.updateUserPhoneNumber(
                                      _auth.currentUser!.uid, _phoneNumber!);
                                }
                                Navigator.of(context)
                                    .pushReplacementNamed('/homepage');
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                        child: const Center(
                          child: Text(
                            'Done',
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(
              height: 200,
            ),
            Center(
              child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.black)),
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/homepage');
                  },
                  child: const Text("Skip for now")),
            )
          ],
        ),
      ),
    );
  }

  Future<void> pickImages(ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _selectedImages = [pickedImage];
      });
    }
  }
}
