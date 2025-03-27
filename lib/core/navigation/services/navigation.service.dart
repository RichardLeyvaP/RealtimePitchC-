import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:singing_app/core/navigation/routes/selected_session.routes.dart';
import 'package:singing_app/core/navigation/routes/singing_sessions.routes.dart';
import 'package:singing_app/features/singing_sessions/domain/singing_session.model.dart';

class AppNavigationService {
  AppNavigationService({
    required this.appRouter,
  });

  final GoRouter appRouter;

  Future<T?> routeTo<T extends Object?>(
    String location, {
    Object? extra,
    bool replaceAll = false,
  }) async {
    if (kIsWeb || replaceAll) {
      appRouter.go(
        location,
        extra: extra,
      );
      return null;
    } else {
      return appRouter.push<T?>(
        location,
        extra: extra,
      );
    }
  }

  bool canPop() => appRouter.canPop();

  void pop<T extends Object?>([T? result]) {
    if (canPop()) {
      appRouter.pop(true);
    }
  }

  void routeToDynamicLocaton({
    required String location,
  }) =>
      appRouter.go(location);

  void routeToSingingSessions() =>
      routeTo(SingingSessionsRoutes.singingSessionsRoute);

  void routeToSelectedSession(SingingSession singingSession) => routeTo(
        SelectedSessionRoutes.selectedSessionRoute,
        extra: singingSession,
        replaceAll: true,
      );

  void routeToSelectedSessionResults() => routeTo(
        SelectedSessionRoutes.selectedSessionResultsRoute,
        replaceAll: true,
      );
}
