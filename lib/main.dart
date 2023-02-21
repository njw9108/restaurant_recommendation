import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:recommend_restaurant/common/const/const_data.dart';
import 'package:recommend_restaurant/common/provider/go_router_provider.dart';
import 'package:recommend_restaurant/firebase_options.dart';
import 'package:recommend_restaurant/restaurant/provider/restaurant_provider.dart';
import 'package:recommend_restaurant/user/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  MyApp({super.key, required this.prefs});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            return AuthProvider(
              firebaseAuth: FirebaseAuth.instance,
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
        Provider<RestaurantProvider>(
          create: (_) {
            return RestaurantProvider(
              prefs: prefs,
            );
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final goRouter = context.watch<GoRouterProvider>().router;

          return MaterialApp.router(
            title: 'recommend restaurants',
            theme: ThemeData(
              fontFamily: 'Paybooc',
            ),
            routerConfig: goRouter,
          );
        },
      ),
    );
  }
}
