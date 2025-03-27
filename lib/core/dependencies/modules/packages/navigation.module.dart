import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';
import 'package:singing_app/core/navigation/services/navigation.service.dart';
import 'package:singing_app/core/navigation/services/router.service.dart';

@module
abstract class NavigationModule {
  @lazySingleton
  GoRouter appRouter() => AppRouterService.initializeAppRouter();

  @lazySingleton
  AppNavigationService appNavigationService(GoRouter appRouter) =>
      AppNavigationService(
        appRouter: appRouter,
      );
}
