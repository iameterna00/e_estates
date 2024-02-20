import 'package:e_estates/widgets/bottom%20_navigation.dart';
import 'package:e_estates/widgets/top_feed.dart';
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
  final List _tags = [
    "Rent",
    "Apartment",
    "Hotel",
    "Shared",
    "Apartment",
    "Hotel",
    "ok"
  ];
  void showError(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

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
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/signup');
      }
    } catch (error) {
      String errorMessage = error.toString();

      // Use a regular expression to remove any text within square brackets and following colon and space, if present
      errorMessage = errorMessage.replaceAll(RegExp(r'\[.*?\]:?\s?'), '');

      showError(errorMessage);
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
                      child: TextButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.transparent)),
                        onPressed: () {
                          Navigator.pushNamed(context, "/themepage");
                        },
                        child: Text(
                          'Hey, $displayName',
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return (const Text("..."));
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                          controller: _locationController,
                          decoration: InputDecoration(
                              hintText:
                                  "Enter your location", // The hint text to display.
                              prefixIcon: const Icon(Icons
                                  .search), // An icon to display at the beginning of the TextField.
                              border: OutlineInputBorder(
                                // Defines the border of the TextField.
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              hintStyle: const TextStyle(),
                              filled: true,
                              fillColor: Colors.transparent)),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {},
                        child: Image.asset('assets/icons/IC_Filter.png'),
                      ))
                ],
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),

                height: 50.0, // Adjust the height to fit your design
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tags.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TextButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                elevation: MaterialStateProperty.all(8.0)),
                            onPressed: () {},
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(
                                _tags[index],
                                style: const TextStyle(fontSize: 18),
                              ),
                            )));
                  },
                ),
              ),
              SizedBox(
                // color: Colors.amber,
                height: 300,
                width: MediaQuery.of(context).size.width,
                //color: Colors.amber,
                child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Near from you',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(child: TopFeed())
                    ]),
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
            Navigator.pushNamed(context, "/picker");
          },
          onChat: () {},
          onProfileTap: () => _signOut(context)),
      appBar: AppBar(),
    );
  }
}
