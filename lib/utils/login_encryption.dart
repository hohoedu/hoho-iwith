import 'package:crypto/crypto.dart';
import 'dart:convert';

/////////////////////////////
//  로그인 비밀번호 암호화  //
/////////////////////////////
String sha256_convertHash(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}
String md5_convertHash(String password) {
  final bytes = utf8.encode(password);
  final hash = md5.convert(bytes);
  return hash.toString();
}