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

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {body}) {
    print(body.toString());
    print("hello before");
    return http.post(Uri.parse(url), body: body).then((http.Response response) {
      print("hello in post berfore res");
      final String res = response.body;
      print("response");
      print(res.toString());
      print("end");
      print("hello in post after res");
      final int statusCode = response.statusCode;
      print("hello in post after code");
      if (statusCode < 200 || statusCode > 400 || json == null) {
        print("hello in if before exception");
        throw new Exception("Error while fetching data");
        print("hello in if after exception");
      }
      print("hello in post after if");
      return _decoder.convert(res);
      print("hello in post before end");
    });
    print("hello after");
  }
}
