import 'package:recommend_restaurant/user/model/login_result.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'social_login.dart';

class AppleLogin implements SocialLogin {
  @override
  Future<LoginResultBase> login() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      return LoginResult(
        accessToken: credential.authorizationCode,
        idToken: credential.identityToken ?? '',
      );
    } catch (e) {
      return LoginCanceled();
    }
  }

  @override
  Future<bool> logout() async {
    return true;
  }

  @override
  Future<bool> withdrawal() async {
    return true;
  }
}
