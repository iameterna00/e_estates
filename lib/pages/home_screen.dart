import 'package:e_estates/widgets/bottom%20_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String userLocation = "Your Location";
  final TextEditingController _locationController = TextEditingController();

  String? displayName;
  String? photourl;

  @override
  void initState() {
    super.initState();
    _reloadUser();
    setState(() {});
    // Fetch the display name of the currently signed-in user
  }

  void _reloadUser() async {
    await _auth.currentUser?.reload();
    setState(() {
      displayName = _auth.currentUser?.displayName;
      photourl = _auth.currentUser?.photoURL;
    });
  }

  void _signOut(signout) async {
    try {
      await _auth.signOut();
      // Optionally, navigate the user to the login screen after signing out
      Navigator.of(context).pushReplacementNamed('/');
    } catch (error) {
      // Handle any errors here
      print("Error signing out: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                  future: _auth.currentUser?.reload(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      displayName = _auth.currentUser?.displayName;
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Hey, $displayName',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    } else {
                      return (const Text("..."));
                    }
                  },
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
                  child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                          hintText:
                              "Enter your location", // The hint text to display.
                          prefixIcon: const Icon(Icons
                              .search), // An icon to display at the beginning of the TextField.
                          border: OutlineInputBorder(
                            // Defines the border of the TextField.
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          hintStyle: const TextStyle(),
                          filled: true,
                          fillColor: Colors.transparent)),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomAppBar(
            auth: _auth,
            onExplore: () {},
            onFavorites: () {},
            onAdd: () {
              Navigator.pushNamed(context, "/themepage");
            },
            onChat: () {},
            onProfileTap: () => _signOut(context)));
  }
}
