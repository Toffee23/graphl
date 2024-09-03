import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:vmodel/src/res/res.dart';

@Deprecated("Use VWidgetsPrimaryButton instead")
Widget vWidgetsInitialButton(Function()? method, String text) {
  return SafeArea(
    left: false,
    right: false,
    child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: VmodelColors.buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: method,
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: VmodelColors.white),
          ).paddingSymmetric(horizontal: 20, vertical: 10),
        )).marginSymmetric(horizontal: 0),
  );
}
