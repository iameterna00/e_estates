import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:e_estates/widgets/explore_maps.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  late SlidingUpPanelController panelController;

  @override
  void initState() {
    super.initState();
    panelController = SlidingUpPanelController();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          ExploreMaps(),
        ],
      ),
    );
  }
}
