// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantModel _$RestaurantModelFromJson(Map<String, dynamic> json) =>
    RestaurantModel(
      id: json['id'] as String?,
      createdAt: json['createdAt'] as int?,
      name: json['name'] as String,
      thumbnail: json['thumbnail'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      images: (json['images'] as List<dynamic>)
          .map((e) => ImageIdUrlData.fromJson(e as Map<String, dynamic>))
          .toList(),
      category: json['category'] as String,
      address: json['address'] as String,
      isVisited: json['isVisited'] as bool,
    );

Map<String, dynamic> _$RestaurantModelToJson(RestaurantModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdAt': instance.createdAt,
      'name': instance.name,
      'thumbnail': instance.thumbnail,
      'tags': instance.tags,
      'rating': instance.rating,
      'comment': instance.comment,
      'images': instance.images,
      'category': instance.category,
      'address': instance.address,
      'isVisited': instance.isVisited,
    };
