import 'package:json_annotation/json_annotation.dart';

part 'my_user_model.g.dart';

@JsonSerializable()
class MyUserModel {
  final String id;
  final String photoUrl;
  final String nickname;
  final String email;

  MyUserModel({
    required this.id,
    required this.photoUrl,
    required this.nickname,
    required this.email,
  });

  factory MyUserModel.fromJson(Map<String, dynamic> json) =>
      _$MyUserModelFromJson(json);

  Map<String, dynamic> toJson() => _$MyUserModelToJson(this);

  MyUserModel copyWith({
    String? id,
    String? photoUrl,
    String? nickname,
    String? email,
  }) {
    return MyUserModel(
      id: id ?? this.id,
      photoUrl: photoUrl ?? this.photoUrl,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
    );
  }
}
