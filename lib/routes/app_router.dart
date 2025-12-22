import 'package:auto_route/auto_route.dart';

import '../presentation_UI/Auth/loginScreen.dart';
import '../presentation_UI/Splash_Screen.dart';
import '../presentation_UI/announcements/announcementAll_Screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  final List<AutoRoute> routes = [
    AutoRoute(page: SplashRoute.page, initial: true),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: AnnouncementallRoute.page),

  ];
}
