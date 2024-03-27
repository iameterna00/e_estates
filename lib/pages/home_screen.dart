import 'package:e_estates/pages/my_profilepage.dart';
import 'package:e_estates/stateManagement/auth_state_provider.dart';
import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:e_estates/widgets/bestfor_you.dart';
import 'package:e_estates/widgets/bottom_navigation.dart';
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
    "Houses",
    "Apartment",
    "Hotel",
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

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/signup');
      }
    } catch (error) {
      String errorMessage = error.toString();

      errorMessage = errorMessage.replaceAll(RegExp(r'\[.*?\]:?\s?'), '');

      showError(errorMessage);
    }
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  String firstName(String displayName) {
    return displayName.split(' ')[0];
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = ref.watch(userProvider).photoURL;
    final displayName = ref.watch(userProvider).name ?? 'there';
    final providerContainer = ProviderScope.containerOf(context);
    final address =
        providerContainer.read(locationNotifierProvider.notifier).address ??
            'Nepal...';
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => refreshData(ref),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8, top: 20, bottom: 10),
                      child: Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const MyProfilePage()));
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: photoUrl != null
                                ? NetworkImage(photoUrl)
                                : const AssetImage('assets/icons/noProfile.png')
                                    as ImageProvider,
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, "/themepage");
                      },
                      child: RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '${greeting()}, ${firstName(displayName)}\n',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const WidgetSpan(
                            child: Icon(Icons.location_pin,
                                size: 14, color: Colors.grey),
                          ),
                          TextSpan(
                            text: address,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ]),
                      ),
                    )
                  ],
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
                /*          Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Image.asset(
                              "assets/icons/findPerson.png",
                              scale: 5,
                            )),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.black
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: Image.asset(
                              "assets/icons/rent.png",
                              scale: 5,
                            )),
                      )
                    ],
                  ),
                ), */
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      height: 50.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _tags.length,
                        itemBuilder: (context, index) {
                          bool isSelected = _tags[index] == _selectedTag;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                backgroundColor: MaterialStateProperty.all(
                                    isSelected
                                        ? Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.black
                                            : Colors.blue
                                        : Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.white
                                            : Colors.black),
                                elevation: MaterialStateProperty.all(8.0),
                              ),
                              onPressed: () {
                                setState(() {
                                  _selectedTag = _tags[index];
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                child: Text(
                                  _tags[index],
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? Colors.black
                                              : Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Near from you',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    padding: EdgeInsets.only(left: 12, right: 12, top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Best for you',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'See more',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
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
          onExplore: () {
            Navigator.pushNamed(context, "/explore");
          },
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
