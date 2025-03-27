import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class PageBuilderService {
  static Page<T> pageBuilder<T>({
    required Widget child,
    bool animateFromTheBottom = false,
  }) {
    if (kIsWeb) {
      return NoTransitionPage<T>(child: child);
    }
    if (animateFromTheBottom) {
      return _AnimatedPage<T>(child: child);
    }
    if (Platform.isAndroid) {
      return NoTransitionPage<T>(child: child);
    }
    return CupertinoPage<T>(
      child: child,
    );
  }
}

class _AnimatedPage<T> extends Page<T> {
  final Widget child;

  _AnimatedPage({required this.child}) : super(key: ValueKey(child));

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this, // Associate the Page with the Route
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const curve = Curves.easeInOut;
        final tween = Tween<Offset>(
          begin: const Offset(0, 1), // Start from bottom
          end: Offset.zero, // End at normal position
        ).chain(CurveTween(curve: curve));

        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
    );
  }
}
