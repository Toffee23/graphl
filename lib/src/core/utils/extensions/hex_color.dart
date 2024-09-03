import 'package:flutter/material.dart';

extension HexColor on String {
  Color get fromHex {
    var hex = this;
    hex = hex.toUpperCase().replaceAll("#", "");
    if (hex.length == 6) {
      hex = "FF$hex";
    }
    final hexNum = int.parse(hex, radix: 16);

    if (hexNum == 0) {
      return const Color(0xff000000);
    }

    return Color(hexNum);
  }
}

class Hex extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }

    final hexNum = int.parse(hexColor, radix: 16);

    if (hexNum == 0) {
      return 0xff000000;
    }

    return hexNum;
  }

  Hex(final String hexColor) : super(_getColorFromHex(hexColor));
}