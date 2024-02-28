import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, LocationData?>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationData?> {
  Location location = Location();
  late final Box<dynamic> locationBox;

  LocationNotifier() : super(null) {
    _initHive();
    fetchUserLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      state = currentLocation;
      _storeLocationInHive(currentLocation);
    });
    configureLocationUpdates();
  }

  void _initHive() async {
    await Hive.initFlutter();
    locationBox = await Hive.openBox('locationBox');
  }

  void _storeLocationInHive(LocationData currentLocation) {
    var locationMap = {
      'latitude': currentLocation.latitude,
      'longitude': currentLocation.longitude,
      'timestamp': currentLocation.time,
    };
    locationBox.put('location', jsonEncode(locationMap));
  }

  LocationData? _getLocationFromHive() {
    var locationString = locationBox.get('location');
    if (locationString != null) {
      var locationMap = jsonDecode(locationString);
      return LocationData.fromMap(locationMap);
    }
    return null;
  }

  Future<void> _fetchOrUseStoredLocation() async {
    var storedLocation = _getLocationFromHive();
    if (storedLocation != null && _isLocationRecent(storedLocation)) {
      // Use the stored location if it's recent enough
      state = storedLocation;
    } else {
      // Fetch a new location if there's no stored location or it's outdated
      await fetchUserLocation();
      if (state == null) {
        // Handle the scenario where fetching the location fails or is not permitted
        // For example, you could set a default location, show an error, etc.
        // Example: state = defaultLocation;
      }
    }
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

  bool _isLocationRecent(LocationData location) {
    // Implement your logic to determine if the location is recent enough
    // For example, consider a location recent if it's less than 10 minutes old
    var currentTime = DateTime.now().millisecondsSinceEpoch;
    var locationTime = location.time!;
    return (currentTime - locationTime) < 600000; // 10 minutes in milliseconds
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

    state = userLocation;
    _storeLocationInHive(userLocation);
  }

  void configureLocationUpdates() {
    location.changeSettings(
        interval: 300000, distanceFilter: 100); // 5 minutes or 100 meters
  }

  Future<double> calculateDistance(
      double destLatitude, double destLongitude) async {
    if (state == null) {
      return -1.0;
    }
    if ((state!.latitude == destLatitude &&
            state!.longitude == destLongitude) ||
        closeEnough(
            state!.latitude!, state!.longitude!, destLatitude, destLongitude)) {
      return 0.0;
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
        print("Total distance in meters: $distanceInMeters");
      }

      return distanceInMeters / 1000.0;
    } else {
      return -1.0;
    }
  }

  bool closeEnough(double lat1, double lon1, double lat2, double lon2) {
    const double threshold = 0.001; // Adjust threshold to your needs
    return (lat1 - lat2).abs() < threshold && (lon1 - lon2).abs() < threshold;
  }
}
