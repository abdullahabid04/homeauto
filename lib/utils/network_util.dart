import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NetworkUtil {
  // next three lines makes this class a Singleton
  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url) {
    return http.get(Uri.parse(url)).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {body}) {
    print(body.toString());
    return http.post(Uri.parse(url), body: body).then((http.Response response) {
      final String res = response.body;
      print(res.toString());
      final int statusCode = response.statusCode;
      return _decoder.convert(res);
    });
  }
}
