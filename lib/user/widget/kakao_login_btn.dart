import 'package:flutter/material.dart';

import '../provider/auth_provider.dart';
import 'social_login_btn.dart';

class KakaoLoginBtn extends StatelessWidget {
  const KakaoLoginBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const SocialLoginBtn(
      type: SignInType.kakao,
      imagePath: 'assets/image/btn_kakao.png',
      tittle: '카카오 로그인',
      fontColor: Colors.black,
      backGroundColor: Color(0xffFEE500),
    );
  }
}
