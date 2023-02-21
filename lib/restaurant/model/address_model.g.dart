// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
      address: json['address_name'] as String?,
      roadAddressName: json['road_address_name'] as String?,
      url: json['place_url'] as String?,
    );

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'address_name': instance.address,
      'road_address_name': instance.roadAddressName,
      'place_url': instance.url,
    };
