import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/widget/overlay_loader.dart';
import '../provider/auth_provider.dart';

class SocialLoginBtn extends StatelessWidget {
  //final Function onLogin;
  final SignInType type;
  final String imagePath;
  final String tittle;
  final Color fontColor;
  final Color backGroundColor;
  final Border? border;

  const SocialLoginBtn({
    Key? key,
    //required this.onLogin,
    required this.type,
    required this.imagePath,
    required this.tittle,
    required this.fontColor,
    required this.backGroundColor,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return InkWell(
      onTap: authProvider.status != LoginStatus.authenticating
          ? () async {
              final overlayLoader = OverlayLoader();
              overlayLoader.showLoading(context);
              await context.read<AuthProvider>().socialSignIn(type);
              overlayLoader.removeLoading();
            }
          : null,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: border,
          color: backGroundColor,
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  imagePath,
                  height: 32,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                tittle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fontColor,
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
