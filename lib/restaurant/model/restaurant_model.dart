import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';

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

  factory RestaurantModel.fromDocument(DocumentSnapshot doc) {
    String name = doc.get(FirestoreRestaurantConstants.name);
    String thumbnail = doc.get(FirestoreRestaurantConstants.thumbnail);
    String restaurantType =
        doc.get(FirestoreRestaurantConstants.restaurantType);
    double rating =
        double.parse(doc.get(FirestoreRestaurantConstants.rating).toString());
    String comment = doc.get(FirestoreRestaurantConstants.comment);
    List<String> images =
        doc.get(FirestoreRestaurantConstants.images)?.cast<String>();
    List<String> categories =
        doc.get(FirestoreRestaurantConstants.categories)?.cast<String>();
    String address = doc.get(FirestoreRestaurantConstants.address);

    return RestaurantModel(
      name: name,
      thumbnail: thumbnail,
      restaurantType: restaurantType,
      rating: rating,
      comment: comment,
      images: images,
      categories: categories,
      address: address,
    );
  }

  Map<String, dynamic> toJson() => _$RestaurantModelToJson(this);
}
