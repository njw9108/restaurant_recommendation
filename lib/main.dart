import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/const/color_schemes.g.dart';
import 'package:recommend_restaurant/common/view/root_tab.dart';
import 'package:recommend_restaurant/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    name: 'restaurant_recommendation',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'recommend restaurants',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
      ),
      themeMode: ThemeMode.system,
      home: const RootTab(),
    );
  }
}