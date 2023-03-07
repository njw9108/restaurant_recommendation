import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:recommend_restaurant/user/repository/firebase_auth_remote_repository.dart';

import '../../common/const/const_data.dart';
import '../model/login_result.dart';
import 'social_login.dart';

class KakaoLogin implements SocialLogin {
  final FirebaseAuthRemoteRepository repository;

  KakaoLogin({
    required this.repository,
  });



  @override
  Future<LoginResultBase> login() async {
    try {
      if (await isKakaoTalkInstalled()) {
        try {
          await UserApi.instance.loginWithKakaoTalk();
          final profileImage = dotenv.env[defaultProfileImage];
          final user = await UserApi.instance.me();

          final customToken = await repository.createCustomToken({
            'uid': user.id.toString(),
            'displayName': user.kakaoAccount?.profile?.nickname ?? '익명유저',
            'email': user.kakaoAccount?.email,
            'photoURL': user.kakaoAccount?.profile?.profileImageUrl ?? profileImage,
          });

          return LoginResult(accessToken: '', idToken: customToken);
        } on DioError catch (e) {
          print(e.response?.statusCode ?? '');
          print(e.message);
          return LoginError(message: e.message);
        } catch (error) {
          // print('카카오톡으로 로그인 실패 $error');

          // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
          // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
          if (error is PlatformException && error.code == 'CANCELED') {
            return LoginCanceled();
          }

          // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
          try {
            await UserApi.instance.loginWithKakaoAccount();
            final profileImage = dotenv.env[defaultProfileImage];
            final user = await UserApi.instance.me();

            final customToken = await repository.createCustomToken({
              'uid': user.id.toString(),
              'displayName': user.kakaoAccount?.profile?.nickname ?? '익명유저',
              'email': user.kakaoAccount?.email,
              'photoURL': user.kakaoAccount?.profile?.profileImageUrl ?? profileImage,
            });

            return LoginResult(accessToken: '', idToken: customToken);
          } catch (error) {
            // print('카카오계정으로 로그인 실패 $error');
            return LoginError(message: error.toString());
          }
        }
      } else {
        try {
          await UserApi.instance.loginWithKakaoAccount();
          final profileImage = dotenv.env[defaultProfileImage];
          final user = await UserApi.instance.me();

          final customToken = await repository.createCustomToken({
            'uid': user.id.toString(),
            'displayName': user.kakaoAccount?.profile?.nickname ?? '익명유저',
            'email': user.kakaoAccount?.email,
            'photoURL': user.kakaoAccount?.profile?.profileImageUrl ?? profileImage,
          });

          return LoginResult(accessToken: '', idToken: customToken);
        } catch (error) {
          // print('카카오계정으로 로그인 실패 $error');
          return LoginError(message: error.toString());
        }
      }
    } catch (error) {
      return LoginError(message: error.toString());
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await UserApi.instance.logout();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> withdrawal() async {
    try {
      await UserApi.instance.unlink();
      return true;
    } catch (e) {
      return false;
    }
  }
}
