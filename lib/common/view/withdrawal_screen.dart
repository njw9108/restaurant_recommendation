import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../user/provider/auth_provider.dart';
import '../const/color.dart';
import '../layout/default_layout.dart';

class WithdrawalScreen extends StatelessWidget {
  static String routeName = 'withdrawal';

  const WithdrawalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
                "그동안 마이슐랭을 이용해주셔서\n감사합니다.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  context.read<AuthProvider>().statusInit();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                ),
                child: const Text('첫화면으로 이동'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
