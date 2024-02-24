import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, LocationData?>((ref) {
  return LocationNotifier();
});

class LocationNotifier extends StateNotifier<LocationData?> {
  Location location = Location();

  LocationNotifier() : super(null) {
    fetchUserLocation();
    location.onLocationChanged.listen((LocationData currentLocation) {
      state = currentLocation;
    });
    configureLocationUpdates();
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
  }

  void configureLocationUpdates() {
    // Frequency and accuracy of location updates
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
      }

      return distanceInMeters / 1000.0;
    } else {
      return 0.0;
    }
  }

  bool closeEnough(double lat1, double lon1, double lat2, double lon2) {
    const double threshold = 0.001; // Adjust threshold to your needs
    return (lat1 - lat2).abs() < threshold && (lon1 - lon2).abs() < threshold;
  }
}
