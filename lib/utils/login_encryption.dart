import 'package:crypto/crypto.dart';
import 'dart:convert';

/////////////////////////////
//  로그인 비밀번호 암호화  //
/////////////////////////////
String sha256_convertHash(String password) {
  final bytes = utf8.encode(password);    // 비밀번호를 바이트로 변환
  final hash = sha256.convert(bytes);     // 비밀번호를 sha256을 통해 해시 코드로 변환
  return hash.toString();
}
String md5_convertHash(String password) {
  final bytes = utf8.encode(password);
  final hash = md5.convert(bytes);
  return hash.toString();
}