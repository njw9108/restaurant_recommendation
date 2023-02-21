import 'package:json_annotation/json_annotation.dart';

part 'address_model.g.dart';

@JsonSerializable()
class AddressModel {
  @JsonKey(name: 'address_name')
  final String? address;
  @JsonKey(name: 'road_address_name')
  final String? roadAddressName;
  @JsonKey(name: 'place_url')
  final String? url;

  AddressModel({
    required this.address,
    required this.roadAddressName,
    required this.url,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) =>
      _$AddressModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddressModelToJson(this);
}
