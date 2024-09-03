import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

extension FormatCurrency on String {
  String formatToPounds() {
    try {
      final formatCurrency = NumberFormat.simpleCurrency(name: 'GBP');
      final format = formatCurrency.format(num.parse(this));

      return format;
    } catch (e) {
      return '$this';
    }
  }

  String get formatToDecimals {
    final numberFormat = NumberFormat(".");
    String formattedText = numberFormat.format(num.parse(this));

    return formattedText;
  }

  String formatToPercentage() {
    try {
      final numberFormat = NumberFormat.percentPattern();
      String formattedText = numberFormat.format(num.parse(this) / 100);
      return formattedText;
    } catch (e) {
      return '$this%';
    }
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    // Handle leading '.' symbol
    if (newValue.text == '.') {
      return TextEditingValue(text: '0.');
    }

    // Handle leading '0' followed by other numbers
    if (newValue.text.startsWith('0') && !newValue.text.startsWith('0.')) {
      return TextEditingValue(text: newValue.text.substring(1));
    }

    // Handle cases where there is only one leading '0' followed by '.'
    if (newValue.text == '0.') {
      return newValue;
    }

    // Handle cases where there is a single '.' symbol
    if (newValue.text == '.') {
      return newValue.copyWith(
        text: '0.',
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    // Split the text to get the integer and decimal parts
    var split = newValue.text.split('.');
    if (split.length > 1) {
      // Handle integer part
      String intValue = split[0];
      // Handle decimal part
      String decValue = split[1];

      // Limit decimal places
      if (decValue.length > decimalRange) {
        decValue = decValue.substring(0, decimalRange);
      }

      // Combine both parts with a '.' symbol
      return TextEditingValue(
        text: '$intValue.$decValue',
        selection: TextSelection.collapsed(
            offset: newValue.selection.end > newValue.text.length
                ? newValue.text.length
                : newValue.selection.end),
      );
    }

    return newValue;
  }
}
