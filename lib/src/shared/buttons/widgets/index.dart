import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../res/colors.dart';

Widget appButton(
  String title,
  Widget? icon,
  Function onPressed,
) {
  return SafeArea(
      child: ElevatedButton(
    onPressed: () => onPressed(),
    style: ButtonStyle(padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 12))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: icon,
          ),
        Text(
          title,
          style: const TextStyle(fontFamily: 'Avenir', fontSize: 14, fontWeight: FontWeight.bold),
        )
      ],
    ),
  ));
}

Widget selectableButton(Function()? method, String text, {bool selected = false}) {
  return SafeArea(
    left: false,
    right: false,
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: selected ? VmodelColors.buttonColor : VmodelColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: VmodelColors.buttonColor)),
        ),
        onPressed: method,
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: selected ? VmodelColors.white : VmodelColors.buttonColor),
          ).paddingSymmetric(horizontal: 8, vertical: 8),
        )),
  );
}
