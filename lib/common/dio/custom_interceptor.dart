import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:recommend_restaurant/common/const/const_data.dart';

class CustomInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {

    if (options.headers['accessToken'] == 'true') {
      options.headers.remove('accessToken');

      final restApiKey = dotenv.env[restAPIKey] ?? '';
      options.headers.addAll({
        'Authorization': 'KakaoAK $restApiKey',
      });
    }

    return super.onRequest(options, handler);
  }
}
