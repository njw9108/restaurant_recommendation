import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:recommend_restaurant/common/const/const_data.dart';
import 'package:recommend_restaurant/common/model/pagination_model.dart';
import 'package:recommend_restaurant/restaurant/model/address_model.dart';

import '../../common/repository/base_pagination_repository.dart';

class KakaoAddressRepository extends IBasePaginationRepository<AddressModel> {
  final Dio dio;
  final String baseUrl = dotenv.env[kakaoBaseUrl] ?? '';

  KakaoAddressRepository({
    required this.dio,
  });

  Future<List<AddressModel>> getAddress({
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
        options: Options(
          headers: {
            'accessToken': 'true',
          },
        ),
      );
      final Iterable iterable = resp.data['documents'];
      final List<AddressModel> result =
          iterable.map((e) => AddressModel.fromJson(e)).toList();

      return result;
    } catch (e) {
      print(e);
      return [];
    }
  }

  @override
  Future<Pagination<AddressModel>> paginate({
    required String query,
    int page = 1,
    int size = 15,
  }) async {
    final resp = await dio.get(
      '$baseUrl/local/search/keyword.json',
      queryParameters: {
        'query': query,
        'page': page,
        'size': size,
      },
      options: Options(
        headers: {
          'accessToken': 'true',
        },
      ),
    );
    final json = resp.data;
    final Pagination<AddressModel> result = Pagination<AddressModel>.fromJson(
        json, (json) => AddressModel.fromJson(json as Map<String, dynamic>));

    return result;
  }
}
