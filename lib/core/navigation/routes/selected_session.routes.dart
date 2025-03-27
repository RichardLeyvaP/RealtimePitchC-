import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:singing_app/core/navigation/services/page_builder.service.dart';
import 'package:singing_app/features/selected_session/selected_session.screen.dart';
import 'package:singing_app/features/selected_session/selected_session_restuls.screen.dart';
import 'package:singing_app/features/singing_sessions/domain/singing_session.model.dart';

class SelectedSessionRoutes {
  SelectedSessionRoutes._();

  static const String selectedSessionRoute = '/selected-session';
  static const String selectedSessionResultsRoute = '/selected-session-results';

  static List<RouteBase> routes = [
    GoRoute(
      path: selectedSessionRoute,
      pageBuilder: (BuildContext context, GoRouterState state) {
        final SingingSession singingSession = state.extra as SingingSession;
        return PageBuilderService.pageBuilder(
          child: SelectedSessionScreen(
            singingSession: singingSession,
          ),
        );
      },
    ),
    GoRoute(
      path: selectedSessionResultsRoute,
      pageBuilder: (BuildContext context, GoRouterState state) {
        return PageBuilderService.pageBuilder(
          child: SelectedSessionResultsScreen(
            scorePercentage: 78,
            sessionNumber: 1,
          ),
        );
      },
    ),
  ];
}
