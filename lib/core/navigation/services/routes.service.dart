import 'package:go_router/go_router.dart';
import 'package:singing_app/core/navigation/routes/selected_session.routes.dart';
import 'package:singing_app/core/navigation/routes/singing_sessions.routes.dart';

class AppRoutesService {
  AppRoutesService._();

  static List<RouteBase> appRoutes = [
    ...SelectedSessionRoutes.routes,
    ...SingingSessionsRoutes.routes,
  ];
}
