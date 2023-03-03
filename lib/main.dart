import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recommend_restaurant/common/dio/custom_interceptor.dart';
import 'package:recommend_restaurant/common/provider/go_router_provider.dart';
import 'package:recommend_restaurant/common/repository/firebase_repository.dart';
import 'package:recommend_restaurant/firebase_options.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_provider.dart';
import 'package:recommend_restaurant/restaurant/repository/kakao_address_repository.dart';
import 'package:recommend_restaurant/user/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home/provider/home_provider.dart';
import 'restaurant/provider/restaurant_add_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'restaurant_recommendation',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Dio>(
          create: (context) {
            final dio = Dio();
            dio.interceptors.add(
              CustomInterceptor(),
            );
            return dio;
          },
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            return AuthProvider(
              googleSignIn: GoogleSignIn(),
              prefs: prefs,
            );
          },
        ),
        ProxyProvider<AuthProvider, GoRouterProvider>(
          update: (BuildContext context, auth, GoRouterProvider? previous) {
            if (previous == null) {
              return GoRouterProvider(
                provider: auth,
              );
            } else {
              return previous;
            }
          },
        ),
        Provider<FirebaseRepository>(
          create: (_) => FirebaseRepository(prefs: prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(),
        ),
        ChangeNotifierProxyProvider2<FirebaseRepository, AuthProvider,
            RestaurantProvider?>(
          create: (_) => null,
          update: (context, firebase, auth, previous) {
            if (previous == null) {
              final provider = RestaurantProvider(
                firebaseRepository: firebase,
                authProvider: auth,
              );
              return provider;
            } else {
              return previous;
            }
          },
        ),
        ProxyProvider<Dio, KakaoAddressRepository>(
          update: (context, dio, previous) {
            if (previous == null) {
              final repository = KakaoAddressRepository(
                dio: dio,
              );
              return repository;
            } else {
              return previous;
            }
          },
        ),
        ChangeNotifierProxyProvider2<KakaoAddressRepository, FirebaseRepository,
            RestaurantAddProvider?>(
          create: (_) => null,
          update: (context, repository, firebase, previous) {
            if (previous == null) {
              final provider = RestaurantAddProvider(
                repository: repository,
                firebaseRepository: firebase,
              );
              return provider;
            } else {
              return previous;
            }
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final goRouter = context.watch<GoRouterProvider>().router;
          final restaurantProvider = context.read<RestaurantProvider>();

          return MaterialApp.router(
            title: 'recommend restaurants',
            theme: ThemeData(
              fontFamily: 'NanumGothic',
            ),
            routerConfig: goRouter,
          );
        },
      ),
    );
  }
}
