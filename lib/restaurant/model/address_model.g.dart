// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AddressModel _$AddressModelFromJson(Map<String, dynamic> json) => AddressModel(
      address: json['address_name'] as String?,
      roadAddressName: json['road_address_name'] as String?,
      url: json['place_url'] as String?,
      place: json['place_name'] as String?,
      categoryName: json['category_name'] as String?,
    );

Map<String, dynamic> _$AddressModelToJson(AddressModel instance) =>
    <String, dynamic>{
      'address_name': instance.address,
      'road_address_name': instance.roadAddressName,
      'place_url': instance.url,
      'place_name': instance.place,
      'category_name': instance.categoryName,
    };
