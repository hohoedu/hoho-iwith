import 'package:dio/dio.dart';

final Dio dio = Dio(
  BaseOptions(
    // baseUrl: "https://hohocenter.co.kr/app",
    baseUrl: "http://192.168.0.136:8080/app",
    contentType: "application/json; charset=utf-8",
  ),
);
