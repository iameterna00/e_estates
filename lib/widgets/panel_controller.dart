import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:latlong2/latlong.dart';

class PanelController extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  const PanelController({super.key, required this.onLocationSelected});

  @override
  State<PanelController> createState() => _PanelControllerState();
}

class _PanelControllerState extends State<PanelController> {
  final TextEditingController _searchController = TextEditingController();
  late SlidingUpPanelController _panelController;
  List<String> _searchResults =
      <String>[]; // Store place names for UI suggestions
  Map<String, dynamic> _placeDetails = {}; // Map place names to their details

  @override
  void initState() {
    super.initState();
    _panelController = SlidingUpPanelController();
  }

  Future<void> searchLocations(String query) async {
    const String bbox = '80.058622,26.347,88.201416,30.422';
    const String apikey =
        'pk.eyJ1IjoiYW5pc2hoLWpvc2hpIiwiYSI6ImNscnl6YWg4NjF1ZWYycW5hNTN1YmRmZWYifQ.Tn3WvzCor5H1w0Fkq9u2aQ';

    final url = Uri.parse(
        'https://api.mapbox.com/geocoding/v5/mapbox.places/$query.json?bbox=$bbox&access_token=$apikey');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      setState(() {
        _searchResults = data['features']
            .map<String>((feature) => feature['place_name'] as String)
            .toList();

        _placeDetails = {
          for (var feature in data['features']) feature['place_name']: feature
        };
      });
    } else {
      setState(() {
        _searchResults = <String>[];
      });
    }
  }

  void onPlaceSelected(String placeName) {
    var placeInfo = _placeDetails[placeName];
    if (placeInfo != null) {
      final coordinates = placeInfo['geometry']['coordinates'];
      final latLng = LatLng(coordinates[1], coordinates[0]);

      widget.onLocationSelected(latLng);
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return SlidingUpPanelWidget(
      controlHeight: 120.0,

      anchor: 0.4, // Panel expands to 40% of the screen
      panelController: _panelController,

      onTap: () {
        // Check the panel's current state and toggle accordingly
        if (_panelController.status == SlidingUpPanelStatus.expanded) {
          _panelController.collapse();
        } else {
          _panelController.anchor();
        }

        // Dismiss the keyboard by removing focus from the text field
        // This line checks if any widget is currently focused and unfocuses it
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: const ShapeDecoration(
          color: Color.fromARGB(255, 56, 56, 56),
          shadows: [
            BoxShadow(
                blurRadius: 5.0, spreadRadius: 2.0, color: Color(0x11000000)),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18.0),
              topRight: Radius.circular(18.0),
            ),
          ),
        ),
        child: _panelContent(),
      ),
    );
  }

  Widget _panelContent() {
    return Column(
      children: [
        const SizedBox(
          height: 50.0,
          child: Center(
            child: Icon(
              Icons.swipe_up,
              color: Color.fromARGB(255, 124, 124, 124),
            ), // Arrow icon
          ),
        ),
        const Divider(
          color: Color.fromARGB(255, 80, 80, 80),
          height: 0.1,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onTap: () {
              if (_panelController.status != SlidingUpPanelStatus.expanded) {
                _panelController.expand();
              }
            },
            controller: _searchController,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search location',
              hintStyle: const TextStyle(color: Colors.white),
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _searchResults = <String>[];
                  });
                },
              ),
            ),
            style: const TextStyle(color: Colors.white),
            onChanged: (String value) async {
              if (value.isNotEmpty) {
                await searchLocations(value);
              } else {
                setState(() {
                  _searchResults = <String>[];
                });
              }
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _searchResults.length,
            itemBuilder: (BuildContext context, int index) {
              final result = _searchResults[index];
              return ListTile(
                title: Text(
                  result,
                  style: const TextStyle(color: Colors.white),
                ),
                // Assuming result is a String
                onTap: () {
                  onPlaceSelected(result);
                  FocusScope.of(context).unfocus();
                  _panelController.collapse();
                  _searchController.text = result;
                },
              );
            },
          ),
        )
      ],
    );
  }
}
