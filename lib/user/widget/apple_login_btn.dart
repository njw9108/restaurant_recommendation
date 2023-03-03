import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../common/widget/overlay_loader.dart';
import '../provider/auth_provider.dart';

class AppleLoginBtn extends StatelessWidget {
  const AppleLoginBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return InkWell(
      onTap: authProvider.status != LoginStatus.authenticating
          ? () async {
        final overlayLoader = OverlayLoader();
        overlayLoader.showLoading(context);
        await context.read<AuthProvider>().signInWithApple();
        overlayLoader.removeLoading();
      }
          : null,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.black,
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/image/btn_apple.png',
                  height: 32,
                ),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Text(
                'Apple 로그인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
