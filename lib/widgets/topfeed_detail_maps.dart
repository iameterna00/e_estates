import 'dart:async';
import 'dart:math';

import 'package:e_estates/models/image_post.dart';
import 'package:e_estates/stateManagement/auth_state_provider.dart';
import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:e_estates/stateManagement/tile_provider.dart';

import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class TopFeedMaps extends StatefulWidget {
  final LatLng? singleHomeLocation;

  final ImagePost? singleHome;
  final bool longPressed;

  const TopFeedMaps(
      {super.key,
      this.singleHomeLocation,
      this.singleHome,
      required this.longPressed});

  @override
  _TopFeedMaps createState() => _TopFeedMaps();
}

class _TopFeedMaps extends State<TopFeedMaps> with TickerProviderStateMixin {
  late final AnimatedMapController _mapController =
      AnimatedMapController(vsync: this);
  late AnimationController _animationController;
  late Animation<double> _animation;
  LatLngBounds? bounds;
  double offset = 0.01;
  bool farCurrentLocation = false;
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
      _setBounds();
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
    } else {}
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
      zoom: 15,
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
      zoom: 15,
    );
  }

  void _setBounds() {
    if (mycurrentLocation != null && myhomelocation != null) {
      Distance distance = const Distance();
      double meterDistance = distance(
        LatLng(mycurrentLocation!.latitude, mycurrentLocation!.longitude),
        LatLng(myhomelocation!.latitude, myhomelocation!.longitude),
      );

      const double thresholdDistance = 10000;

      if (meterDistance > thresholdDistance) {
        setState(() {
          farCurrentLocation = true;
        });
        // If the locations are far apart, set the bounds around the home location only
        bounds = LatLngBounds(
          LatLng(myhomelocation!.latitude - offset,
              myhomelocation!.longitude - offset),
          LatLng(myhomelocation!.latitude + offset,
              myhomelocation!.longitude + offset),
        );
      } else {
        // If the locations are near each other, set the bounds to include both locations
        double minLat =
            min(mycurrentLocation!.latitude, myhomelocation!.latitude);
        double maxLat =
            max(mycurrentLocation!.latitude, myhomelocation!.latitude);
        double minLng =
            min(mycurrentLocation!.longitude, myhomelocation!.longitude);
        double maxLng =
            max(mycurrentLocation!.longitude, myhomelocation!.longitude);

        bounds = LatLngBounds(
          LatLng(minLat - offset, minLng - offset),
          LatLng(maxLat + offset, maxLng + offset),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose(); // Don't forget to dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer(
              builder: (context, ref, child) {
                final theme = Theme.of(context).brightness;
                ref.watch(cachedTileProviderFamily(
                  theme == Brightness.dark
                      ? "https://api.maptiler.com/maps/bright-v2-dark/{z}/{x}/{y}.png?key=rl2E7qJsNHe3PFmq0WjI"
                      : "https://api.maptiler.com/maps/streets-v2-light/{z}/{x}/{y}.png?key=rl2E7qJsNHe3PFmq0WjI",
                ));

                return FlutterMap(
                  mapController: _mapController.mapController,
                  options: MapOptions(
                    initialCenter:
                        myhomelocation ?? const LatLng(27.700769, 85.300140),
                    initialZoom: 15,
                    maxZoom: 16,
                    interactiveFlags: widget.longPressed
                        ? InteractiveFlag.drag
                        : InteractiveFlag.none,
                    maxBounds: bounds,
                  ),
                  children: <Widget>[
                    TileLayer(
                      tileProvider: CachedTileProvider(
                        urlTemplate:
                            "https://api.mapbox.com/styles/v1/mapbox/dark-v11/tiles/{z}/{x}/{y}?style=mapbox://styles/mapbox/outdoors-v12?optimize=true&access_token=pk.eyJ1IjoiYW5pc2hoLWpvc2hpIiwiYSI6ImNscnl6YWg4NjF1ZWYycW5hNTN1YmRmZWYifQ.Tn3WvzCor5H1w0Fkq9u2aQ",
                        cacheBox: Hive.box(
                            Theme.of(context).brightness == Brightness.dark
                                ? 'darkTileCache'
                                : 'lightTileCache'),
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
                              myhomelocation!.longitude),
                          child: Column(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      width: 1),
                                  image: DecorationImage(
                                    image: (widget
                                                .singleHome!.imageUrls.isNotEmpty
                                            ? NetworkImage(widget
                                                .singleHome!.imageUrls.first)
                                            : const AssetImage(
                                                'assets/Icons/noProfile.png'))
                                        as ImageProvider<Object>,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(
                                widget.singleHome!.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
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
                                            color: Colors.blue.withOpacity(0.5),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Consumer(
                                    builder: (BuildContext context,
                                        WidgetRef ref, Widget? child) {
                                      final photoUrl =
                                          ref.watch(userProvider)?.photoUrl;
                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Image.asset(
                                              "assets/icons/Current_location_marker.png"),
                                          if (photoUrl != null &&
                                              photoUrl.isNotEmpty)
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
                                            ),
                                          if (photoUrl == null ||
                                              photoUrl.isEmpty)
                                            Container(
                                              width: 20,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                      color: Colors.black)),
                                              child: const ClipOval(
                                                  child: Icon(
                                                Icons.person,
                                                size: 15,
                                                color: Colors.grey,
                                              )),
                                            ),
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
                        onTap: () =>
                            (Uri.parse('https://openstreetmap.org/copyright')),
                      ),
                    ])
                  ],
                );
              },
            ),
      if (farCurrentLocation == false)
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
                  padding: const EdgeInsets.all(5),
                ),
                child: Icon(
                  Icons.my_location,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      Positioned(
        right: 20,
        top: farCurrentLocation == true ? 30 : 80,
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _movetohomeLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(5),
              ),
              child: Icon(
                Icons.home,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                size: 20,
              ),
            ),
          ],
        ),
      ),
      Positioned(
        left: 10,
        bottom: 10,
        child: RichText(
          text: TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: widget.singleHome!.location,
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w600,
                  fontSize: 8,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
              const WidgetSpan(
                child: Icon(
                  Icons.location_pin,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    ]);
  }
}
