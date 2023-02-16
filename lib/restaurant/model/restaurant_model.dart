import 'package:json_annotation/json_annotation.dart';

part 'restaurant_model.g.dart';

@JsonSerializable()
class RestaurantModel {
  final String name;
  final String thumbnail;
  final String restaurantType;
  final double rating;
  final String comment;
  final List<String> images;
  final List<String> categories;
  final String address;

  RestaurantModel({
    required this.name,
    required this.thumbnail,
    required this.restaurantType,
    required this.rating,
    required this.comment,
    required this.images,
    required this.categories,
    required this.address,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantModelFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantModelToJson(this);
}
