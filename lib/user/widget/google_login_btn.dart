import 'package:flutter/material.dart';

import '../provider/auth_provider.dart';
import 'social_login_btn.dart';

class GoogleLoginBtn extends StatelessWidget {
  const GoogleLoginBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SocialLoginBtn(
      type: SignInType.google,
      imagePath: 'assets/image/btn_google.png',
      tittle: 'Google 로그인',
      fontColor: Colors.black,
      backGroundColor: Colors.white,
      border: Border.all(color: Colors.black26),
    );
  }
}
