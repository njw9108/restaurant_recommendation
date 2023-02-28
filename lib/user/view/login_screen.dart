import 'dart:io';

import 'package:flutter/material.dart';
import 'package:recommend_restaurant/common/const/color.dart';
import 'package:recommend_restaurant/common/layout/default_layout.dart';

import '../widget/apple_login_btn.dart';
import '../widget/google_login_btn.dart';
import '../widget/kakao_login_btn.dart';

class LoginScreen extends StatelessWidget {
  static String routeName = 'login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SafeArea(
        top: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  _Title(),
                  SizedBox(height: 8,),
                  _SubTitle(),
                ],
              ),
              Column(
                children: [
                  const KakaoLoginBtn(),
                  const SizedBox(
                    height: 24,
                  ),
                  const GoogleLoginBtn(),
                  const SizedBox(
                    height: 24,
                  ),
                  if (Platform.isIOS) const AppleLoginBtn(),
                ],
              ),
            ],
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
      '마이슐랭 시작하기',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'My Eating Table',
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: BODY_TEXT_COLOR,
      ),
    );
  }
}
