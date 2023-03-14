import 'package:json_annotation/json_annotation.dart';

part 'login_result.g.dart';

abstract class LoginResultBase {}

class LoginError implements LoginResultBase {
  final String message;

  LoginError({
    required this.message,
  });
}

class LoginCanceled implements LoginResultBase {}

@JsonSerializable()
class LoginResult implements LoginResultBase {
  String accessToken;
  String idToken;

  LoginResult({
    required this.accessToken,
    required this.idToken,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) =>
      _$LoginResultFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResultToJson(this);
}
