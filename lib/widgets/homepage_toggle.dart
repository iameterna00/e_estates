import 'package:e_estates/pages/home_screen.dart';
import 'package:e_estates/widgets/explore_maps.dart';
import 'package:flutter/material.dart';

class HomeToggle extends StatelessWidget {
  // This is our shared state
  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier(0);

  HomeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    // Widgets for the views
    final List<Widget> widgetOptions = [
      const HomeScreen(), // Widget for finding rooms
      const ExploreMaps(), // Widget for exploring maps
    ];

    return Scaffold(
      body: Column(
        children: <Widget>[
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => _selectedIndexNotifier.value = 0,
                  child: const Text('Find Rooms'),
                ),
                ElevatedButton(
                  onPressed: () => _selectedIndexNotifier.value = 1,
                  child: const Text('Explore Maps'),
                ),
              ],
            ),
          ),
          // Using ValueListenableBuilder to listen to changes
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _selectedIndexNotifier,
              builder: (context, selectedIndex, child) {
                // Display selected view
                return widgetOptions.elementAt(selectedIndex);
              },
            ),
          ),
        ],
      ),
    );
  }
}
