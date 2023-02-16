import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/common/view/root_tab.dart';
import 'package:recommend_restaurant/user/provider/auth_provider.dart';
import 'package:recommend_restaurant/user/view/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = 'splash';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        context.read<AuthProvider>().checkLogin();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: MediaQuery.of(context).size.width / 2,
              color: PRIMARY_COLOR,
            ),
            const SizedBox(
              height: 16,
            ),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
