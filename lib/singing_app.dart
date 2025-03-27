import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:singing_app/core/dependencies/dependencies.dart';
import 'package:singing_app/core/design_system/theme/theme.dart';

class SingingApp extends StatelessWidget {
  const SingingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: getIt<GoRouter>(),
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      builder: ((
        BuildContext context,
        Widget? child,
      ) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: child,
        );
      }),
    );
  }
}
