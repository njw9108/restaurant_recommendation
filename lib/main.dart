import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:recommend_restaurant/common/dio/custom_interceptor.dart';
import 'package:recommend_restaurant/common/provider/go_router_provider.dart';
import 'package:recommend_restaurant/common/repository/firebase_repository.dart';
import 'package:recommend_restaurant/firebase_options.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_provider.dart';
import 'package:recommend_restaurant/restaurant/repository/kakao_address_repository.dart';
import 'package:recommend_restaurant/user/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/user/repository/firebase_auth_remote_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'common/const/const_data.dart';
import 'common/provider/app_version_provider.dart';
import 'home/provider/home_provider.dart';
import 'restaurant/provider/restaurant_add_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'restaurant_recommendation',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load();
  String appkey = dotenv.env[nativeAppKey] ?? '';
  KakaoSdk.init(
    nativeAppKey: appkey,
  );

  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  runApp(const MyApp(secureStorage: secureStorage));
}

class MyApp extends StatelessWidget {
  final FlutterSecureStorage secureStorage;

  const MyApp({super.key, required this.secureStorage});

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
        Provider<FirebaseRepository>(
          create: (_) => FirebaseRepository(secureStorage: secureStorage),
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
        ProxyProvider<Dio, FirebaseAuthRemoteRepository>(
          update: (context, dio, previous) {
            if (previous == null) {
              final repository = FirebaseAuthRemoteRepository(
                dio: dio,
              );
              return repository;
            } else {
              return previous;
            }
          },
        ),
        ChangeNotifierProxyProvider2<FirebaseAuthRemoteRepository,
            FirebaseRepository, AuthProvider?>(
          create: (_) => null,
          update:
              (context, authRemoteRepository, firebaseRepository, previous) {
            if (previous == null) {
              return AuthProvider(
                secureStorage: secureStorage,
                firebaseAuthRemoteRepository: authRemoteRepository,
                firebaseRepository: firebaseRepository,
              );
            } else {
              return previous;
            }
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
                secureStorage: secureStorage,
              );
              return provider;
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
        ChangeNotifierProvider<AppVersionProvider>(
          create: (_) => AppVersionProvider(),
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
