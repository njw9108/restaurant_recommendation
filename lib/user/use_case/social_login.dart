import '../model/login_result.dart';

abstract class SocialLogin {
  Future<LoginResultBase> login();

  Future<bool> logout();

  Future<bool> withdrawal();
}
