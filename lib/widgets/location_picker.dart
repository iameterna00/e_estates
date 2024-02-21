import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:e_estates/widgets/panel_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPickerMap extends StatefulWidget {
  final Function(LatLng)? onLocationSelected;

  const LocationPickerMap({super.key, this.onLocationSelected});

  @override
  _LocationPickerMapState createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap>
    with TickerProviderStateMixin {
  late final AnimatedMapController _mapController =
      AnimatedMapController(vsync: this);
  late AnimationController _animationController;
  late Animation<double> _animation;

  LatLng? mycurrentLocation;
  LatLng? selectedLocation;
  bool _isLoading = true;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _locateMyCurrentPosition();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _profilePictureUrl = user.photoURL;
        });
      }
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800), // Adjust duration to control speed
    )..repeat(reverse: true); // Causes the animation to auto-reverse

    _animation = Tween<double>(
      begin: 0.9, // Starting scale
      end: 1.1, // Ending scale (slightly larger)
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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

    _mapController.animateTo(
      dest: mycurrentLocation!,
      zoom: 15.0,
    );
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
        child: Stack(
          children: [
            _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator while loading
                : FlutterMap(
                    mapController: _mapController.mapController,
                    options: MapOptions(
                      initialCenter:
                          mycurrentLocation ?? LatLng(27.700769, 85.300140),
                      initialZoom: 15,
                      maxBounds: LatLngBounds(
                        const LatLng(26.347, 80.058622),
                        const LatLng(30.422, 88.201416),
                      ),
                      onTap: (_, point) {
                        setState(() {
                          selectedLocation =
                              point; // Update selectedLocation with the point tapped on the map
                        });
                      },
                    ),
                    children: <Widget>[
                      TileLayer(
                        urlTemplate:
                            "https://api.mapbox.com/styles/v1/anishh-joshi/clsvji7sm004p01qub28pf5n3/tiles/{z}/{x}/{y}?access_token=pk.eyJ1IjoiYW5pc2hoLWpvc2hpIiwiYSI6ImNscnl6YWg4NjF1ZWYycW5hNTN1YmRmZWYifQ.Tn3WvzCor5H1w0Fkq9u2aQ",
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
                                                animation: _animationController,
                                                builder: (context, child) {
                                                  return Transform.scale(
                                                    scale: _animation.value,
                                                    child: Container(
                                                      width:
                                                          20, // Adjust based on the size of your marker
                                                      height:
                                                          20, // Adjust based on the size of your marker
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
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipOval(
                                                    child: _profilePictureUrl !=
                                                            null
                                                        ? Image.network(
                                                            _profilePictureUrl!,
                                                            fit: BoxFit.cover,
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
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15),
                    ),
                    child: Icon(Icons.my_location,
                        color: const Color.fromARGB(255, 98, 183, 252)),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _confirmLocation(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(15),
                    ),
                    child: Icon(Icons.check,
                        color: const Color.fromARGB(255, 98, 183, 252)),
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
          ],
        ),
      ),
    );
  }

  void _confirmLocation() {
    LatLng locationToConfirm = selectedLocation ?? mycurrentLocation!;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location confirmed!')),
    );

    Navigator.pop(context, locationToConfirm);
  }
}
