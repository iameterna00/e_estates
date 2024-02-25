import 'package:e_estates/widgets/bestfor_you.dart';
import 'package:e_estates/widgets/bottom%20_navigation.dart';
import 'package:e_estates/widgets/top_feed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../stateManagement/top_feed_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String userLocation = "Your Location";
  final TextEditingController _locationController = TextEditingController();
  final List _tags = [
    "All",
    "Rent",
    "Apartment",
    "Hotel",
    "Shared",
    "Apartment",
    "Hotel",
    "ok"
  ];
  String _selectedTag = "All";

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
      body: RefreshIndicator(
        onRefresh: () => refreshData(ref),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.transparent)),
                          onPressed: () {
                            Navigator.pushNamed(context, "/themepage");
                          },
                          child: Text(
                            'Hey, $displayName',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.start,
                          ),
                        ),
                      );
                    } else {
                      return (const Text("Hey"));
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
                                hintText: "Enter your location",
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                hintStyle: const TextStyle(fontSize: 14),
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
                  height: 50.0,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tags.length,
                    itemBuilder: (context, index) {
                      bool isSelected = _tags[index] ==
                          _selectedTag; // Check if the tag is selected
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: TextButton(
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isSelected
                                    ? BorderSide(color: Colors.blue, width: 2)
                                    : BorderSide(color: Colors.transparent),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all(
                              isSelected
                                  ? Colors.lightBlueAccent.withOpacity(0.2)
                                  : Colors.black,
                            ),
                            elevation: MaterialStateProperty.all(8.0),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedTag = _tags[index];
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              _tags[index],
                              style: TextStyle(
                                  fontSize: 18,
                                  color: isSelected
                                      ? Colors.blue
                                      : Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.white
                                          : Colors.white),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Near from you',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                TopFeed(
                  selectedTag: _selectedTag,
                ),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Best for you',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                BestForYou(
                  selectedTag: _selectedTag,
                )
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomAppBar(
          onExplore: () {},
          onFavorites: () {},
          onAdd: () {
            Navigator.pushNamed(context, "/picker");
          },
          onChat: () {},
          onProfileTap: () => _signOut(context)),
    );
  }

  Future<void> refreshData(WidgetRef ref) async {
    await ref.read(topFeedProvider.notifier).refreshPosts();
  }
}
