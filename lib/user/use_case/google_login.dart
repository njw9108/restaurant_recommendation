import 'package:google_sign_in/google_sign_in.dart';

import '../model/login_result.dart';
import 'social_login.dart';

class GoogleLogin implements SocialLogin {
  final _googleSignIn = GoogleSignIn();

  @override
  Future<LoginResultBase> login() async {
    try {
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final googleAuth = await googleUser.authentication;
        return LoginResult(
          accessToken: googleAuth.accessToken ?? '',
          idToken: googleAuth.idToken ?? '',
        );
      } else {
        return LoginCanceled();
      }
    } catch (e) {
      return LoginError(message: e.toString());
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> withdrawal() {
    // TODO: implement withdrawal
    throw UnimplementedError();
  }
}
