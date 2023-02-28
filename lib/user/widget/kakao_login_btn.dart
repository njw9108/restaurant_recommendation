import 'package:flutter/material.dart';

class KakaoLoginBtn extends StatelessWidget {
  const KakaoLoginBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xffFEE500),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/image/btn_kakao.png',
                height: 32,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              '카카오 로그인',
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
    );
  }
}
