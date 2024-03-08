import 'dart:async';
import 'package:e_estates/stateManagement/location_provider.dart';
import 'package:e_estates/stateManagement/tile_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_estates/widgets/panel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPickerMap extends StatefulWidget {
  final Function(LatLng)? onLocationSelected; //NO USE??

  const LocationPickerMap({
    super.key,
    this.onLocationSelected,
  });

  @override
  _LocationPickerMapState createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap>
    with TickerProviderStateMixin {
  late final AnimatedMapController _mapController =
      AnimatedMapController(vsync: this);
  late AnimationController _animationController;
  late Animation<double> _animation;
  final TextEditingController _searchControllerlite = TextEditingController();
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
      duration:
          const Duration(milliseconds: 800), // Adjust duration to control speed
    )..repeat(reverse: true); // Causes the animation to auto-reverse

    _animation = Tween<double>(
      begin: 0.9, // Starting scale
      end: 1.1, // Ending scale (slightly larger)
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _fetchCurrentLocation() async {
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
      updateLocationName();
    } else {
      _locateMyCurrentPosition();
    }
  }

  String buildLocationName(Placemark place) {
    List<String> locationParts = [];

    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      locationParts.add(place.subLocality!);
    }

    if (place.street != null && place.street!.isNotEmpty) {
      locationParts.add(place.street!);
    }

    if (place.locality != null && place.locality!.isNotEmpty) {
      locationParts.add(place.locality!);
    }

    return locationParts.join(', ');
  }

  void updateLocationName() async {
    final providerContainer = ProviderScope.containerOf(context);
    final currentLocation = providerContainer
        .read(locationNotifierProvider.notifier)
        .currentLocation;
    if (currentLocation != null) {
      // Fetch the placemark data for the current location
      List<Placemark> placemarks = await placemarkFromCoordinates(
          currentLocation.latitude!, currentLocation.longitude!);

      Placemark place = placemarks.first;

      // Iterate over the placemarks until a non-empty street name is found
      for (Placemark p in placemarks) {
        if (p.street != null &&
            p.street!.isNotEmpty &&
            !p.street!.contains(RegExp(r'[!@#\$%^&*(),.?"+:{}|<>]'))) {
          place = p;
          break;
        }
      }

      String locationName = buildLocationName(place);

      // Update the search bar with the location name
      setState(() {
        _searchControllerlite.text = locationName;
      });
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
        context: context,
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

  //LOCATE CURRENT POSITION

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
    updateLocationName();
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
        child: Stack(
          children: [
            _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator while loading
                : Consumer(builder: (context, ref, child) {
                    final theme = Theme.of(context).brightness;
                    ref.watch(cachedTileProviderFamily(
                      theme == Brightness.dark
                          ? "https://api.maptiler.com/maps/bright-v2-dark/{z}/{x}/{y}.png?key=rl2E7qJsNHe3PFmq0WjI"
                          : "https://api.maptiler.com/maps/streets-v2-light/{z}/{x}/{y}.png?key=rl2E7qJsNHe3PFmq0WjI",
                    ));
                    return FlutterMap(
                      mapController: _mapController.mapController,
                      options: MapOptions(
                        initialCenter: mycurrentLocation ??
                            const LatLng(27.700769, 85.300140),
                        initialZoom: 15,
                        maxBounds: LatLngBounds(
                          const LatLng(26.347, 80.058622),
                          const LatLng(30.422, 88.201416),
                        ),
                        onTap: (_, point) async {
                          setState(() {
                            selectedLocation =
                                point; // Update selectedLocation with the point tapped on the map
                          });

                          // Reverse geocode the selected location
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                            selectedLocation!.latitude,
                            selectedLocation!.longitude,
                          );

                          // Check if we got any results
                          if (placemarks.isNotEmpty) {
                            Placemark place = placemarks.first;

                            // Iterate over the placemarks until a non-empty street name is found
                            for (Placemark p in placemarks) {
                              if (p.street != null &&
                                  p.street!.isNotEmpty &&
                                  !p.street!.contains(
                                      RegExp(r'[!@#\$%^&*(),.?"+:{}|<>]'))) {
                                place = p;
                                break;
                              }
                            }

                            String locationNameSelected =
                                buildLocationName(place);
                            // Update the search bar with the location name
                            setState(() {
                              _searchControllerlite.text = locationNameSelected;
                            });
                          }
                        },
                      ),
                      children: <Widget>[
                        TileLayer(
                          tileProvider: CachedTileProvider(
                            urlTemplate: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? "https://api.maptiler.com/maps/bright-v2-dark/{z}/{x}/{y}.png?key=rl2E7qJsNHe3PFmq0WjI"
                                : "https://api.maptiler.com/maps/streets-v2-light/{z}/{x}/{y}.png?key=rl2E7qJsNHe3PFmq0WjI",
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
                            if (selectedLocation != null)
                              Marker(
                                point: selectedLocation!,
                                child: Builder(
                                    builder: (ctx) => Stack(
                                            alignment: Alignment.center,
                                            clipBehavior: Clip.none,
                                            children: [
                                              Image.asset(
                                                  'assets/icons/Near Pin Marker.png',
                                                  width: 40,
                                                  height: 40),
                                              Positioned(
                                                bottom: -5,
                                                child: AnimatedBuilder(
                                                  animation:
                                                      _animationController,
                                                  builder: (context, child) {
                                                    return Transform.scale(
                                                      scale: _animation.value,
                                                      child: Container(
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.blue
                                                              .withOpacity(0.5),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ])),
                              ),
                            if (selectedLocation == null)
                              Marker(
                                  point: mycurrentLocation!,
                                  child: Builder(
                                      builder: (ctx) => Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              AnimatedBuilder(
                                                animation: _animationController,
                                                builder: (context, child) {
                                                  return Transform.scale(
                                                    scale: _animation.value,
                                                    child: Container(
                                                      width:
                                                          40, // Adjust based on the size of your marker
                                                      height:
                                                          40, // Adjust based on the size of your marker
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.blue
                                                            .withOpacity(
                                                                0.5), // Semi-transparent blue circle
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              Image.asset(
                                                  'assets/icons/Current_location_marker.png'),
                                              Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipOval(
                                                      child:
                                                          _profilePictureUrl !=
                                                                  null
                                                              ? Image.network(
                                                                  _profilePictureUrl!,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : null))
                                            ],
                                          )))
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
                  }),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _confirmLocation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(15),
                    ),
                    child: const Icon(Icons.check,
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
            PanelController(
              onLocationSelected: (LatLng latlng) {
                setState(() {
                  selectedLocation = latlng;
                });
                _mapController.animateTo(dest: latlng, zoom: 15);
              },
              onLocationNameUpdated: (String newName) {
                setState(() {
                  _searchControllerlite.text =
                      newName; // Directly update the LocationName state variable with newName
                });
              },
              initialLocationName: _searchControllerlite.text,
            )
          ],
        ),
      ),
    );
  }

  void _confirmLocation() async {
    LatLng locationToConfirm = selectedLocation ?? mycurrentLocation!;
    String locationName = _searchControllerlite.text;

    if (locationName.isEmpty) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), Text("Please wait")],
            ),
          );
        },
      );

      int attempts = 0;
      while (locationName.isEmpty && attempts < 30) {
        await Future.delayed(Duration(milliseconds: 500));
        locationName = _searchControllerlite.text;
        attempts++;
      }

      // Once the location name is fetched, dismiss the dialog
      Navigator.of(context).pop();
    }

    // Confirm the location and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location confirmed!')),
    );

    Navigator.pop(context, {
      'latitude': locationToConfirm.latitude,
      'longitude': locationToConfirm.longitude,
      'Location': locationName,
    });
  }
}
