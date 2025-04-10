import 'package:flutter/material.dart';
import '../../style.dart';

///////////////////////////////
// 아이디,비밀번호 입력 박스 ///
///////////////////////////////

InputDecoration loginBoxDecoration(text, {passwordVisibleController}) {

  return InputDecoration(
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffeff9ff),),
      borderRadius: BorderRadius.all(Radius.circular(20))),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xffd5eafc), width: 2),
      borderRadius: BorderRadius.all(Radius.circular(20))),
    contentPadding: const EdgeInsets.only(left: 20),

    suffixIcon: text == "비밀번호"
    ? IconButton(
      icon: Icon(
        passwordVisibleController.passwordVisible.value
          ? Icons.visibility
          : Icons.visibility_off,
        color: CommonColors.grey4,
      ),
      onPressed: passwordVisibleController.switchPasswordVisibility
    )
    : null
  );
}