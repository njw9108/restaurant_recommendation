import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widget/overlay_loader.dart';
import '../provider/auth_provider.dart';

class GoogleLoginBtn extends StatelessWidget {
  const GoogleLoginBtn({
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
              await context.read<AuthProvider>().signIn();
              overlayLoader.removeLoading();
            }
          : null,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black26),
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/image/btn_google.png',
                  height: 32,
                ),
              ),
            ),
            const Expanded(
              flex: 2,
              child: Text(
                'Google 로그인',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
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
