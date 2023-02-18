import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';
import 'package:recommend_restaurant/common/widget/overlay_loader.dart';
import 'package:recommend_restaurant/user/provider/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  static String routeName = 'login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    // if (authProvider.status == LoginStatus.authenticating) {}

    return DefaultLayout(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Title(),
                const SizedBox(
                  height: 16,
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: authProvider.status != LoginStatus.authenticating
                      ? () async {
                          final overlayLoader = OverlayLoader();

                          overlayLoader.showLoading(context);
                          await context.read<AuthProvider>().signIn();
                          overlayLoader.removeLoading();
                        }
                      : null,
                  child: const Text('Sign in with Google'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      '환영합니다!',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: Colors.black,
        fontFamily: 'Paybooc',
      ),
    );
  }
}
