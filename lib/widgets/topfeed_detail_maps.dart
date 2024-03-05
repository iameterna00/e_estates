import 'dart:async';

import 'package:e_estates/service/image_post.dart';
import 'package:e_estates/stateManagement/auth_state_provider.dart';
import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:e_estates/stateManagement/tile_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class TopFeedMaps extends StatefulWidget {
  final LatLng? singleHomeLocation;
  final String? singleHomeImage;
  final ImagePost? singleHome;

  const TopFeedMaps(
      {super.key,
      this.singleHomeLocation,
      this.singleHomeImage,
      this.singleHome});

  @override
  _TopFeedMaps createState() => _TopFeedMaps();
}

class _TopFeedMaps extends State<TopFeedMaps> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController =
      AnimatedMapController(vsync: this);
  late AnimationController _animationController;
  late Animation<double> _animation;

  LatLng? mycurrentLocation;

  LatLng? myhomelocation;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    //  _locateMyCurrentPosition();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _homeLocation();
      _fetchCurrentLocation();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _homeLocation() {
    if (widget.singleHomeLocation != null) {
      setState(() {
        mycurrentLocation = LatLng(widget.singleHomeLocation!.latitude,
            widget.singleHomeLocation!.longitude);
        _isLoading = false;
      });
      _movetohomeLocation();
    } else {
      //  _locateMyCurrentPosition();
    }
  }

  void _fetchCurrentLocation() {
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
  }

  void _moveToCurrentPosition() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    final currentLocation = LatLng(position.latitude, position.longitude);

    setState(() {
      mycurrentLocation = currentLocation;
    });
    _mapController.animateTo(
      dest: mycurrentLocation!,
      zoom: 15.0,
    );
  }

  void _movetohomeLocation() async {
    final homeLocation = LatLng(widget.singleHomeLocation!.latitude,
        widget.singleHomeLocation!.longitude);

    setState(() {
      myhomelocation = homeLocation;
    });
    _mapController.animateTo(
      dest: homeLocation,
      zoom: 15.0,
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
                      initialCenter:
                          myhomelocation ?? const LatLng(27.700769, 85.300140),
                      initialZoom: 15,
                      maxZoom: 16,
                      maxBounds: LatLngBounds(
                        const LatLng(26.347, 80.058622),
                        const LatLng(30.422, 88.201416),
                      ),
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
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80,
                            height: 80,
                            rotate: true,
                            point: LatLng(myhomelocation!.latitude,
                                mycurrentLocation!.longitude),
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                    image: DecorationImage(
                                      image:
                                          NetworkImage(widget.singleHomeImage!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.singleHome!.title,
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
                                              color:
                                                  Colors.blue.withOpacity(0.5),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    Consumer(
                                      builder: (BuildContext context,
                                          WidgetRef ref, Widget? child) {
                                        final photoUrl =
                                            ref.watch(userProvider).photoURL;
                                        return Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.asset(
                                                "assets/icons/Current_location_marker.png"),
                                            if (photoUrl != null)
                                              Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                        color: Colors.white)),
                                                child: ClipOval(
                                                  child: Image.network(
                                                    photoUrl,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              )
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              )),
                        ],
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
          right: 20,
          top: 80,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _movetohomeLocation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.home,
                    color: Color.fromARGB(255, 98, 183, 252)),
              ),
            ],
          ),
        ),
      ]),
    ));
  }
}
