import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart' as geo;

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, LocationData?>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationData?> {
  Location location = Location();
  late final Box<dynamic> locationBox;
  final distanceCache = <String, double>{};
  LocationData? get currentLocation => state;
  String? address;

  LocationNotifier() : super(null) {
    _initHive();
    getOptimizedLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      state = currentLocation;
      _storeLocationInHive(currentLocation);
    });
    configureLocationUpdates();
  }

  Future<String> getStreetNameAndCity(LocationData currentLocation) async {
    List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
      currentLocation.latitude!,
      currentLocation.longitude!,
    );

    geo.Placemark place = placemarks[0];

    return '${place.country}, ${place.locality}';
  }

  void _initHive() async {
    await Hive.initFlutter();
    locationBox = await Hive.openBox('locationBox');
  }

  void _storeLocationInHive(LocationData currentLocation) async {
    String address = await getStreetNameAndCity(currentLocation);
    this.address = address;
    var locationMap = {
      'latitude': currentLocation.latitude,
      'longitude': currentLocation.longitude,
      'timestamp': currentLocation.time,
      'address': address,
    };
    locationBox.put('location', jsonEncode(locationMap));
  }

  Future<LocationData?> getOptimizedLocation() async {
    var storedLocation = _getLocationFromHive();
    if (storedLocation != null && _isLocationRecent(storedLocation)) {
      return storedLocation;
    } else {
      await fetchUserLocation();
      return state;
    }
  }

  Future<void> fetchUserLocation() async {
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        state = null;
        return;
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        state = null;
        return;
      }
    }

    var userLocation = await location.getLocation();
    // Add this line
    state = userLocation;
    _storeLocationInHive(userLocation);
  }

  LocationData? _getLocationFromHive() {
    var locationString = locationBox.get('location');
    if (locationString != null) {
      var locationMap = jsonDecode(locationString);
      return LocationData.fromMap(locationMap);
    }
    return null;
  }

  bool _isLocationRecent(LocationData location) {
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var locationTime = location.time!;
    return (currentTime - locationTime) < 300000; // 5 minutes in milliseconds
  }

  void configureLocationUpdates() {
    location.changeSettings(interval: 300000, distanceFilter: 100);
  }

  Future<dynamic> calculateDistance(
      double destLatitude, double destLongitude) async {
    final cacheKey = '$destLatitude-$destLongitude';
    final cachedDistance = distanceCache[cacheKey];
    if (cachedDistance != null) {
      return cachedDistance;
    }

    if (state == null) {
      List<geo.Placemark> placemarks =
          await geo.placemarkFromCoordinates(destLatitude, destLongitude);
      return placemarks.first.name ?? 'Nepal ';
    }
    if (closeEnough(
        state!.latitude!, state!.longitude!, destLatitude, destLongitude)) {
      return 0.0;
    }

    const double radius = 1.5;
    double straightLineDistance = Geolocator.distanceBetween(
          state!.latitude!,
          state!.longitude!,
          destLatitude,
          destLongitude,
        ) /
        1000;

    if (straightLineDistance > radius) {
      return '';
    }

    // Prepare the API request
    String apiKey =
        'pk.eyJ1IjoiYW5pc2hoLWpvc2hpIiwiYSI6ImNscnl6YWg4NjF1ZWYycW5hNTN1YmRmZWYifQ.Tn3WvzCor5H1w0Fkq9u2aQ';
    var url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/${state!.longitude},${state!.latitude};$destLongitude,$destLatitude?geometries=geojson&access_token=$apiKey');
    // Make the request
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      var distanceInMeters = 0.0;
      for (var leg in jsonResponse['routes'][0]['legs']) {
        distanceInMeters += leg['distance'] as double;
      }

      final distanceInKm = distanceInMeters / 1000.0;
      distanceCache[cacheKey] = distanceInKm;
      return distanceInKm;
    } else {
      return -1.0;
    }
  }

  bool closeEnough(double lat1, double lon1, double lat2, double lon2) {
    const double threshold = 0.001;
    return (lat1 - lat2).abs() < threshold && (lon1 - lon2).abs() < threshold;
  }
}
