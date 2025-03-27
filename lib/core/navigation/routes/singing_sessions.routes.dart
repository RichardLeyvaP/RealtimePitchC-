import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:singing_app/features/singing_sessions/presentation/screens/singing_sessions.screen.dart';

class SingingSessionsRoutes {
  SingingSessionsRoutes._();

  static const String singingSessionsRoute = '/';

  static List<RouteBase> routes = [
    GoRoute(
      path: singingSessionsRoute,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return NoTransitionPage(
          child: SingingSessionsScreen(),
        );
      },
    ),
  ];
}
