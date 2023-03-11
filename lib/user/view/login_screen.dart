import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 50.h),
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Title(),
                  SizedBox(
                    height: 8.h,
                  ),
                  const _SubTitle(),
                ],
              ),
              Column(
                children: [
                  const KakaoLoginBtn(),
                  SizedBox(
                    height: 24.h,
                  ),
                  const GoogleLoginBtn(),
                  SizedBox(
                    height: 24.h,
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
    return Image.asset(
      'assets/image/main_logo.png',
      width: MediaQuery.of(context).size.width / 2,
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'My Eating Table',
      style: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        color: GRAY_COLOR,
      ),
    );
  }
}
