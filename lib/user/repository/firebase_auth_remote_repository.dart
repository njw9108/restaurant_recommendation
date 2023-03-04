import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../common/const/const_data.dart';

class FirebaseAuthRemoteRepository {
  final Dio dio;

  FirebaseAuthRemoteRepository({
    required this.dio,
  });

  final String url = dotenv.env[customTokenApi] ?? '';

  Future<String> createCustomToken(Map<String, dynamic> user) async {
    try {
      final customTokenResponse = await dio.post(url, data: user);
      return customTokenResponse.data;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
