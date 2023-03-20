import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const/color.dart';
import '../layout/default_layout.dart';

class AppUpdateScreen extends StatelessWidget {
  static String routeName = 'app_update';

  const AppUpdateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: REdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: REdgeInsets.all(52.0),
                child: Image.asset(
                  'assets/image/main_logo.png',
                ),
              ),
              Text(
                "새로운 업데이트가 있습니다",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "현재 버전은 더이상 지원하지 않습니다.\n새로워진 마이슐랭을 경험해보세요!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14.sp, color: Colors.black54, height: 1.5),
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: () async {
                  Platform.isAndroid
                      ? await launchUrl(
                          Uri.parse(
                              "https://play.google.com/store/apps/details?id=com.njw9108.recommend_restaurant"),
                        )
                      : await launchUrl(
                          Uri.parse("https://apps.apple.com/us/app/%EB%A7%88%EC%9D%B4%EC%8A%90%EB%9E%AD/id6446059984"),
                        );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                ),
                child: const Text('지금 업데이트 하기'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
