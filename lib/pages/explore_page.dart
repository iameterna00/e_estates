import 'package:e_estates/widgets/bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:e_estates/widgets/explore_maps.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  ExplorePageState createState() => ExplorePageState();
}

class ExplorePageState extends State<ExplorePage> {
  late SlidingUpPanelController panelController;

  @override
  void initState() {
    super.initState();
    panelController = SlidingUpPanelController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomAppBar(
        onExplore: () {
          Navigator.pushNamed(context, "/explore");
        },
        onFavorites: () {},
        onAdd: () {
          Navigator.pushNamed(context, "/picker");
        },
        onChat: () {},
      ),
      body: const Stack(
        children: [
          ExploreMaps(),
        ],
      ),
    );
  }
}
