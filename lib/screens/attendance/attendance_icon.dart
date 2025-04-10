import 'package:flutter/material.dart';
import 'package:flutter_application/constants.dart';
import 'package:flutter_application/widgets/imagebox_decoration.dart';

///////////////////
//  출결 아이콘  //
///////////////////

const double attendanceIconSize = 18;

// 출결 상태 아이콘
Widget attendanceStatusIcon(status) {
  if (attendanceStatusList.containsKey(status)) {
    return Icon(
      attendanceStatusList[status]!['icon'] as IconData?,
      size: attendanceIconSize,
      color: attendanceStatusList[status]!['color'] as Color?,
    );
  } else {
    return const SizedBox(width: attendanceIconSize, height: attendanceIconSize);
  }
}

// 출결 과목 아이콘
Widget attendanceSubjectIcon(subject) {
  if (subjectImageList.containsKey(subject)) {
    return Container(
      height: attendanceIconSize,
      width: attendanceIconSize,
      decoration: imageBoxDecoration(subjectImageList[subject].toString(), BoxFit.contain)
    );
  } else {
    return const SizedBox(width: attendanceIconSize, height: attendanceIconSize);
  }
}