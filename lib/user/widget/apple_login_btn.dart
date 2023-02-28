import 'package:flutter/material.dart';

class AppleLoginBtn extends StatelessWidget {
  const AppleLoginBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black,
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/image/btn_apple.png',
                height: 32,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'Apple 로그인',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
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
