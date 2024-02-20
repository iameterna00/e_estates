import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPickerMap extends StatefulWidget {
  const LocationPickerMap({super.key});

  @override
  _LocationPickerMapState createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  final MapController _mapController = MapController();
  LatLng? mycurrentLocation;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _locateMyCurrentPosition();
  }

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

  Future<void> _locateMyCurrentPosition() async {
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
      _mapController.move(mycurrentLocation!, 15.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: mycurrentLocation ?? LatLng(27.700769, 85.300140),
        initialZoom: 7.0,
        maxBounds: LatLngBounds(
          LatLng(26.347, 80.058622), // Southwest corner of Nepal
          LatLng(30.422, 88.201416), // Northeast corner of Nepal
        ),
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate:
              'https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=rl2E7qJsNHe3PFmq0WjI',
          additionalOptions: const {
            'apiKey': 'rl2E7qJsNHe3PFmq0WjI',
          },
          userAgentPackageName: 'com.example.e_estates',
        ),
        RichAttributionWidget(attributions: [
          TextSourceAttribution('OpenStreetMap contributors',
              onTap: () => (Uri.parse('https://openstreetmap.org/copyright')))
        ]),
        MarkerLayer(markers: [
          if (mycurrentLocation != null)
            Marker(
                point: mycurrentLocation!,
                child: Builder(
                    builder: (context) => const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                        )))
        ])
      ],
    );
  }
}
