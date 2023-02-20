import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:recommend_restaurant/common/view/root_tab.dart';
import 'package:recommend_restaurant/common/view/splash_screen.dart';
import 'package:recommend_restaurant/restaurant/model/restaurant_model.dart';
import 'package:recommend_restaurant/restaurant/view/restaurant_add_screen.dart';
import 'package:recommend_restaurant/restaurant/view/restaurant_detail_screen.dart';
import 'package:recommend_restaurant/user/provider/auth_provider.dart';
import 'package:recommend_restaurant/user/view/login_screen.dart';

class GoRouterProvider {
  final AuthProvider provider;

  GoRouterProvider({
    required this.provider,
  }) {
    _router = GoRouter(
      routes: routes,
      initialLocation: '/splash',
      refreshListenable: provider,
      redirect: redirectLogic,
    );
  }

  late GoRouter _router;

  GoRouter get router => _router;

  List<GoRoute> routes = [
    GoRoute(
      path: '/',
      name: RootTab.routeName,
      builder: (_, state) => const RootTab(),
      routes: [
        GoRoute(
          path: 'restaurantAdd',
          name: RestaurantAddScreen.routeName,
          builder: (_, state) => const RestaurantAddScreen(),
        ),
        GoRoute(
          path: 'restaurantDetail',
          name: RestaurantDetailScreen.routeName,
          builder: (_, state) {
            final RestaurantModel model = state.extra as RestaurantModel;
            return RestaurantDetailScreen(
              model: model,
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/splash',
      name: SplashScreen.routeName,
      builder: (_, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: LoginScreen.routeName,
      builder: (_, state) => const LoginScreen(),
    ),
  ];

  String? redirectLogic(BuildContext context, GoRouterState state) {
    final loggingIn = state.location == '/login';

    //유저 정보가 없는데 로그인 중이라면 그대로 로그인 페이지에 두고
    //만약 로그인 중이 아니라면 로그인 페이지로 이동
    if (provider.status == LoginStatus.uninitialized) {
      return loggingIn ? null : '/login';
    }

    //usermodel(사용자 정보가 있음)
    //로그인 중이거나 현재 위치가 Splash Screen -> 홈으로 이동
    if (provider.status == LoginStatus.authenticated &&
        provider.userModel != null) {
      return loggingIn || state.location == '/splash' ? '/' : null;
    }

    //user model error
    if (provider.status == LoginStatus.authenticateError) {
      return !loggingIn ? '/login' : null;
    }

    return null;
  }
}
