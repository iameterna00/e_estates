import 'package:e_estates/pages/home_screen.dart';
import 'package:e_estates/widgets/explore_maps.dart';
import 'package:flutter/material.dart';

class PageSwipeController extends StatefulWidget {
  const PageSwipeController({super.key});

  @override
  PageSwipeControllerState createState() => PageSwipeControllerState();
}

class PageSwipeControllerState extends State<PageSwipeController> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void swipePage() {
    final nextPage = _pageController.page?.round() == 0 ? 1 : 0;
    _pageController.animateToPage(nextPage,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: const [
        HomeScreen(),
        ExploreMaps(),
      ],
    );
  }
}
