import 'package:flutter/services.dart';

class NoSpecialCharactersFormatter extends TextInputFormatter{
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final newText = newValue.text;
    final filteredText = newText.replaceAll(
      RegExp(r'[^a-zA-Z0-9 ]'), '');
    return newValue.copyWith(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length)
    );
  }

}