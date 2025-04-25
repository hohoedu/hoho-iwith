import 'package:flutter/material.dart';
import 'package:flutter_application/_core/style.dart';

///////////////////////////////
// 아이디,비밀번호 입력 박스 ///
///////////////////////////////

InputDecoration loginBoxDecoration(text, {passwordVisibleController}) {
  return InputDecoration(
      fillColor: Color(0xFFEFF3F6),
      enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFEFF3F6),
          ),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFEFF3F6), width: 2),
          borderRadius: BorderRadius.all(Radius.circular(20))),
      contentPadding: const EdgeInsets.only(left: 20),
      suffixIcon: text == "비밀번호"
          ? IconButton(
              icon: Icon(
                passwordVisibleController.passwordVisible.value ? Icons.visibility : Icons.visibility_off,
                color: CommonColors.grey4,
              ),
              onPressed: passwordVisibleController.switchPasswordVisibility)
          : null);
}
