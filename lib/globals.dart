// globals.dart ✅
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const Color bgColor = Color(0xFFF2EDE6);
//const Color bgColor = Color(0xFFE5EFDF);
const Color secColor = Color(0xFFC9B29B);
//const Color thirdColor = Color(0xFF82AC9D);
const Color thirdColor = Color(0xFF9C6B3F);
//const Color secColor = Color(0xFF91602A);
const Color darkColor = Color(0xFF4A2C24);
//const Color darkColor = Color(0xFF4A2F26);
const Color verydarkcolor = Color(0xFF2D1B15);

double getScale(BuildContext context) {
  double width = MediaQuery.of(context).size.width;
  if (width > 1200) return 1.4;
  if (width > 600) return 1.2;
  return 1.0;
}
final ValueNotifier<int> navigationIndex = ValueNotifier<int>(0);