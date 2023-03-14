// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MyUserModel _$MyUserModelFromJson(Map<String, dynamic> json) => MyUserModel(
      id: json['id'] as String,
      photoUrl: json['photoUrl'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
    );

Map<String, dynamic> _$MyUserModelToJson(MyUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'photoUrl': instance.photoUrl,
      'nickname': instance.nickname,
      'email': instance.email,
    };
