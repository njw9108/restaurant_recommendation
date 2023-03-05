import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/common/provider/app_version_provider.dart';
import 'package:recommend_restaurant/common/view/update_screen.dart';
import 'package:recommend_restaurant/user/provider/auth_provider.dart';

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
      Future.delayed(const Duration(milliseconds: 500), () async {
        final isValidVersion = await context.read<AppVersionProvider>().checkAppVersion();
        if (isValidVersion) {
          context.read<AuthProvider>().checkLogin();
        } else {
          context.goNamed(
            AppUpdateScreen.routeName,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.all(52.0),
              child: Image.asset(
                'assets/image/main_logo.png',
              ),
            ),
            const LinearProgressIndicator(
              backgroundColor: Color(0xffc5c5c5),
              color: PRIMARY_COLOR,
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

}
