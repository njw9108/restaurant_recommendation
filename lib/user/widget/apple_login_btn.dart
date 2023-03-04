import 'package:flutter/material.dart';

import '../provider/auth_provider.dart';
import 'social_login_btn.dart';

class AppleLoginBtn extends StatelessWidget {
  const AppleLoginBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SocialLoginBtn(
      type: SignInType.apple,
      imagePath: 'assets/image/btn_apple.png',
      tittle: 'Apple 로그인',
      fontColor: Colors.white,
      backGroundColor: Colors.black,
    );
  }
}
