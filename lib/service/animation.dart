import 'package:e_estates/service/themechanger.dart';
import 'package:flutter/material.dart';

class NoTransparencyPageRoute<T> extends PageRoute<T> {
  NoTransparencyPageRoute({this.builder});

  final WidgetBuilder? builder;

  @override
  Color get barrierColor => Colors.transparent;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    // Ensure the page has a Material widget to provide an opaque background.
    return Material(
      child: builder!(context),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0), // Start from the right
        end: Offset.zero, // End at the center (no offset)
      ).animate(animation),
      child: Material(
        color: AppThemes.darkTheme
            .scaffoldBackgroundColor, // Directly use the color from your theme class
        child: child,
      ),
    );
  }
}
