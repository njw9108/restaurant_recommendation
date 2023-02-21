import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:recommend_restaurant/common/const/const_data.dart';
import 'package:recommend_restaurant/restaurant/model/address_model.dart';

class KakaoAddressRepository {
  final Dio dio;
  final String baseUrl = dotenv.env[kakaoBaseUrl] ?? '';

  KakaoAddressRepository({
    required this.dio,
  });

  Future<AddressModel?> getAddress({
    required String place,
    int page = 1,
    int size = 15,
  }) async {
    try {
      final resp = await dio.get(
        '$baseUrl/local/search/keyword.json',
        queryParameters: {
          'query': place,
          'page': page,
          'size': size,
        },
      );
      final AddressModel model = AddressModel.fromJson(resp.data);
      return model;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
