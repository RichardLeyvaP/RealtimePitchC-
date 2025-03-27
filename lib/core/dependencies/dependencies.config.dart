// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:go_router/go_router.dart' as _i583;
import 'package:injectable/injectable.dart' as _i526;
import 'package:singing_app/core/dependencies/modules/packages/navigation.module.dart'
    as _i52;
import 'package:singing_app/core/navigation/services/navigation.service.dart'
    as _i598;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final navigationModule = _$NavigationModule();
  gh.lazySingleton<_i583.GoRouter>(() => navigationModule.appRouter());
  gh.lazySingleton<_i598.AppNavigationService>(
      () => navigationModule.appNavigationService(gh<_i583.GoRouter>()));
  return getIt;
}

class _$NavigationModule extends _i52.NavigationModule {}
