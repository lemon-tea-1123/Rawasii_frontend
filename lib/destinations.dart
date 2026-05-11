//
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rawasii/globals.dart';

Widget _svgIcon(String path, {bool active = false}) {
  return SvgPicture.asset(
    path,
    width: 35,
    height: 35,
    colorFilter: ColorFilter.mode(
      active ? thirdColor : darkColor, // your app colors
      BlendMode.srcIn,
    ),
  );
}


