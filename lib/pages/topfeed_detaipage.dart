import 'package:e_estates/service/image_post.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class TopFeedDetail extends StatelessWidget {
  final ImagePost detailpagepost;

  const TopFeedDetail({super.key, required this.detailpagepost});
  Future<double> _calculateDistance(
      double destLatitude, double destLongitude) async {
    var location = Location();

    // Ensure the service is enabled and permissions are granted
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return -1; // Service not enabled, cannot calculate distance
      }
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return -1; // Permissions not granted, cannot calculate distance
      }
    }

    // Obtain the current location
    var userLocation = await location.getLocation();

    // Ensure userLocation has valid data
    if (userLocation.latitude == null || userLocation.longitude == null) {
      return -1.0; // Indicate an error
    }

    // Prepare the API request
    String apiKey =
        'pk.eyJ1IjoiYW5pc2hoLWpvc2hpIiwiYSI6ImNscnl6YWg4NjF1ZWYycW5hNTN1YmRmZWYifQ.Tn3WvzCor5H1w0Fkq9u2aQ';
    var url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving/${userLocation.longitude},${userLocation.latitude};$destLongitude,$destLatitude?geometries=geojson&access_token=$apiKey');
    // Make the request
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);

      // Parse the distance from the API response
      // Note: Mapbox returns distances in meters for each leg of the trip
      var distanceInMeters = 0.0;
      for (var leg in jsonResponse['routes'][0]['legs']) {
        distanceInMeters += leg['distance'] as double;
      }

      return distanceInMeters / 1000.0; // Convert meters to kilometers
    } else {
      // Handle request error
      print('Request failed with status: ${response.statusCode}.');
      return -1.0; // Indicate an error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SingleChildScrollView(
        child: BottomAppBar(
          elevation: 0,
          height: 75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Price'),
              Text(
                'Rs. ${detailpagepost.title}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Image.network(detailpagepost.imageUrl),
                      Positioned.fill(
                          child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent
                              ])),
                        ),
                      )),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Text(
                          detailpagepost.title,
                          style: const TextStyle(
                              //  fontFamily: GoogleFonts.raleway().fontFamily,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      Positioned(
                          top: 10,
                          right: 10,
                          child: InkWell(
                            onTap: () {},
                            child: Image.asset('assets/icons/IC_Bookmark.png'),
                          )),
                      Positioned(
                          top: 10,
                          left: 10,
                          child: InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, "/homepage");
                            },
                            child: Image.asset('assets/icons/IC_Back.png'),
                          ))
                      // Add more widgets to display other details about the post
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Description',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(detailpagepost.description),
              ),
              FutureBuilder<double>(
                future: _calculateDistance(
                    detailpagepost.latitude, detailpagepost.longitude),
                builder:
                    (BuildContext context, AsyncSnapshot<double> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else {
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');
                    else
                      return Text('Distance: ${snapshot.data} Km');
                  }
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Your action here
        },
        label: Text('Rent Now',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                fontFamily: GoogleFonts.raleway().fontFamily)),
        //  icon: Icon(Icons.home),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

        /*   materialTapTargetSize:
            MaterialTapTargetSize.shrinkWrap, */ // Minimizes the padding
        isExtended: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
