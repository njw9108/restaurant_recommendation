import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(52.0),
                child: Image.asset(
                  'assets/image/main_logo.png',
                ),
              ),
              const Text(
                "새로운 업데이트가 있습니다",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "현재 버전은 더이상 지원하지 않습니다.\n새로워진 마이슐랭을 경험해보세요!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  // Platform.isAndroid
                  //     ? await launchUrl(
                  //         Uri.parse(
                  //             "https://play.google.com/store/apps/details?id=com.beside04.haruNyang"),
                  //       )
                  //     : await launchUrl(
                  //         Uri.parse("https://apps.apple.com/app/id6444657575"),
                  //       );
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
