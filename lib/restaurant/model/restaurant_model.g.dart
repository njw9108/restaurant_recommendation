// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantModel _$RestaurantModelFromJson(Map<String, dynamic> json) =>
    RestaurantModel(
      name: json['name'] as String,
      thumbnail: json['thumbnail'] as String,
      restaurantType: json['restaurantType'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      address: json['address'] as String,
    );

Map<String, dynamic> _$RestaurantModelToJson(RestaurantModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'thumbnail': instance.thumbnail,
      'restaurantType': instance.restaurantType,
      'rating': instance.rating,
      'comment': instance.comment,
      'images': instance.images,
      'categories': instance.categories,
      'address': instance.address,
    };
