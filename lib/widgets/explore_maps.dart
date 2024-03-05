import 'dart:async';
import 'package:e_estates/service/image_post.dart';
import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:e_estates/stateManagement/tile_provider.dart';
import 'package:e_estates/stateManagement/top_feed_provider.dart';
import 'package:e_estates/widgets/panel_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class ExploreMaps extends StatefulWidget {
  final Function(LatLng)? onLocationSelected;
  final LatLng? singleHomeLocation;

  const ExploreMaps(
      {super.key, this.onLocationSelected, this.singleHomeLocation});

  @override
  _ExploreMaps createState() => _ExploreMaps();
}

class _ExploreMaps extends State<ExploreMaps> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController =
      AnimatedMapController(vsync: this);
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<ImagePost> imagePosts = [];

  LatLng? mycurrentLocation;
  LatLng? selectedLocation;
  bool _isLoading = true;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _requestPermissions();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchCurrentLocation();
    });

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _profilePictureUrl = user.photoURL;
        });
      }
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.9, // Starting scale
      end: 1.1, // Ending scale (slightly larger)
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _fetchCurrentLocation() {
    // Access the provider using the context, which is now available
    final providerContainer = ProviderScope.containerOf(context);
    final currentLocation = providerContainer
        .read(locationNotifierProvider.notifier)
        .currentLocation;
    if (currentLocation != null) {
      setState(() {
        mycurrentLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
        _isLoading = false;
      });
      _moveToCurrentPosition();
    } else {
      _locateMyCurrentPosition();
    }
  }

  //PERMISSION

  Future<void> _requestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
        context: (context),
        builder: (BuildContext context) => AlertDialog(
          title: const Text("Location Permissions"),
          content: const Text(
              "Location permissions are permanently denied. Please open app settings to grant permissions."),
          actions: <Widget>[
            TextButton(
              child: const Text("Open Settings"),
              onPressed: () {
                openAppSettings(); // Function to open app settings
              },
            ),
          ],
        ),
      );
      return;
    }
  }

  Future<void> _locateMyCurrentPosition() async {
    setState(() {
      _isLoading = true; // Indicate that loading has started
    });
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location Service are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permisssion are denied');
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      mycurrentLocation = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    _moveToCurrentPosition();
  }

  void _moveToCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final currentLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      mycurrentLocation = currentLocation;
      selectedLocation = null;
    });
    _mapController.animateTo(
      dest: mycurrentLocation!,
      zoom: 15.0, // Adjust zoom level as needed
      // Add rotation or tilt if desired
    );
  }

  @override
  void dispose() {
    _animationController.dispose(); // Don't forget to dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Consumer(
                builder: (context, ref, child) {
                  ref.watch(cachedTileProviderFamily(
                    "https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}?style=mapbox://styles/mapbox/outdoors-v12?optimize=true&access_token=pk.eyJ1IjoiYW5pc2hoLWpvc2hpIiwiYSI6ImNscnl6YWg4NjF1ZWYycW5hNTN1YmRmZWYifQ.Tn3WvzCor5H1w0Fkq9u2aQ",
                  ));

                  return FlutterMap(
                    mapController: _mapController.mapController,
                    options: MapOptions(
                      initialCenter: mycurrentLocation ??
                          const LatLng(27.700769, 85.300140),
                      initialZoom: 15,
                      maxZoom: 16,
                      maxBounds: LatLngBounds(
                        const LatLng(26.347, 80.058622),
                        const LatLng(30.422, 88.201416),
                      ),
                      onTap: (_, point) {
                        setState(() {
                          selectedLocation = point;
                        });
                      },
                    ),
                    children: <Widget>[
                      TileLayer(
                        tileProvider: CachedTileProvider(
                          urlTemplate:
                              "https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}?style=mapbox://styles/mapbox/outdoors-v12?optimize=true&access_token=pk.eyJ1IjoiYW5pc2hoLWpvc2hpIiwiYSI6ImNscnl6YWg4NjF1ZWYycW5hNTN1YmRmZWYifQ.Tn3WvzCor5H1w0Fkq9u2aQ",
                          cacheBox: Hive.box('tileCache'),
                        ),
                        additionalOptions: const {
                          'apiKey':
                              'pk.eyJ1IjoiYW5pc2hoLWpvc2hpIiwiYSI6ImNscnl6YWg4NjF1ZWYycW5hNTN1YmRmZWYifQ.Tn3WvzCor5H1w0Fkq9u2aQ'
                        },
                        userAgentPackageName: 'com.example.e_estates',
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final imagePostsAsyncValue =
                              ref.watch(topFeedProvider);
                          return imagePostsAsyncValue.when(
                            data: (imagePosts) {
                              print(
                                  "Number of image posts: ${imagePosts.length}");
                              return MarkerLayer(
                                rotate: true,
                                markers: [
                                  ...imagePosts.map((ImagePost post) => Marker(
                                      width: 80.0,
                                      height: 80.0,
                                      point:
                                          LatLng(post.latitude, post.longitude),
                                      child: Builder(
                                        builder: (ctx) => GestureDetector(
                                          onTap: () {
                                            // Handle tap if necessary
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.white,
                                                        width: 1),
                                                    image: DecorationImage(
                                                        image: NetworkImage(post
                                                            .imageUrls.first),
                                                        fit: BoxFit.cover)),
                                              ),
                                              Text(
                                                post.title,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ))),
                                  if (selectedLocation != null)
                                    Marker(
                                      point: selectedLocation!,
                                      child: const Icon(
                                        Icons.location_pin,
                                        size: 40,
                                      ),
                                    ),
                                  if (widget.singleHomeLocation != null)
                                    Marker(
                                      point: widget.singleHomeLocation!,
                                      child: const Icon(
                                        Icons.location_pin,
                                        size: 40,
                                      ),
                                    ),
                                  Marker(
                                      point: mycurrentLocation!,
                                      child: Builder(
                                        builder: (ctx) => Stack(
                                          alignment: Alignment.center,
                                          children: <Widget>[
                                            // Your current location marker animation
                                            AnimatedBuilder(
                                              animation: _animationController,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: _animation.value,
                                                  child: Container(
                                                    width: 40,
                                                    height: 40,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.blue
                                                          .withOpacity(0.5),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            Image.asset(
                                                'assets/icons/Current_location_marker.png'),
                                            if (_profilePictureUrl != null)
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle),
                                                child: ClipOval(
                                                  child: Image.network(
                                                      _profilePictureUrl!,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                          ],
                                        ),
                                      )),
                                ],
                              );
                            },
                            loading: () => const MarkerLayer(markers: []),
                            error: (error, stack) =>
                                const MarkerLayer(markers: []),
                          );
                        },
                      ),
                      RichAttributionWidget(attributions: [
                        TextSourceAttribution(
                          'OpenStreetMap contributors',
                          onTap: () => (Uri.parse(
                              'https://openstreetmap.org/copyright')),
                        ),
                      ])
                    ],
                  );
                },
              ),
        Positioned(
          right: 20,
          top: 30,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _moveToCurrentPosition,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.my_location,
                    color: Color.fromARGB(255, 98, 183, 252)),
              ),
            ],
          ),
        ),
        Positioned(
            left: 20,
            top: 30,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Image.asset('assets/icons/IC_Back.png'),
            )),
        PanelController(onLocationSelected: (LatLng latlng) {
          setState(() {
            selectedLocation = latlng;
          });
          _mapController.animateTo(dest: latlng, zoom: 15);
        }),
      ]),
    ));
  }
}
