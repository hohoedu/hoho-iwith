import 'package:dio/dio.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: "https://hohoschool.com/iwith",
    contentType: "application/json; charset=utf-8",
  ),
);
