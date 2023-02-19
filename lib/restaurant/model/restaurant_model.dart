import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:recommend_restaurant/common/const/firestore_constants.dart';

part 'restaurant_model.g.dart';

@JsonSerializable()
class RestaurantModel {
  final String? id;
  final String name;
  final String thumbnail;
  final List<String> tags;
  final double rating;
  final String comment;
  final List<String> images;
  final String category;
  final String address;

  RestaurantModel({
    this.id,
    required this.name,
    required this.thumbnail,
    required this.tags,
    required this.rating,
    required this.comment,
    required this.images,
    required this.category,
    required this.address,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) =>
      _$RestaurantModelFromJson(json);

  factory RestaurantModel.fromDocument(DocumentSnapshot doc) {
    String id = doc.get(FirestoreRestaurantConstants.restaurantId);
    String name = doc.get(FirestoreRestaurantConstants.name);
    String thumbnail = doc.get(FirestoreRestaurantConstants.thumbnail);
    List<String> tags =
        doc.get(FirestoreRestaurantConstants.tags)?.cast<String>();
    double rating =
        double.parse(doc.get(FirestoreRestaurantConstants.rating).toString());
    String comment = doc.get(FirestoreRestaurantConstants.comment);
    List<String> images =
        doc.get(FirestoreRestaurantConstants.images)?.cast<String>();
    String category = doc.get(FirestoreRestaurantConstants.category);
    String address = doc.get(FirestoreRestaurantConstants.address);

    return RestaurantModel(
      id: id,
      name: name,
      thumbnail: thumbnail,
      rating: rating,
      comment: comment,
      images: images,
      address: address,
      tags: tags,
      category: category,
    );
  }

  Map<String, dynamic> toJson() => _$RestaurantModelToJson(this);

  RestaurantModel copyWith({
    String? id,
    String? name,
    String? thumbnail,
    List<String>? tags,
    double? rating,
    String? comment,
    List<String>? images,
    String? category,
    String? address,
  }) {
    return RestaurantModel(
      id: id ?? id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      images: images ?? this.images,
      category: category ?? this.category,
      address: address ?? this.address,
    );
  }
}
