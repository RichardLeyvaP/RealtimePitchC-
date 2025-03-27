import 'package:singing_app/core/navigation/services/routes.service.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class AppRouterService {
  AppRouterService._();

  static final GlobalKey<NavigatorState> mainNavigatorKey =
      GlobalKey(debugLabel: 'Main Navigator');

  static GoRouter initializeAppRouter() {
    return GoRouter(
      routes: AppRoutesService.appRoutes,
      navigatorKey: mainNavigatorKey,
    );
  }
}
