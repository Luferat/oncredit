// lib/tools/formatters.dart

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Formatters {
  static final dateFormat = DateFormat('dd/MM/yyyy');

  static final currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  static final currencyInput = TextInputFormatter.withFunction(
        (oldValue, newValue) {
      final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

      if (digits.isEmpty) {
        return const TextEditingValue(text: '');
      }

      final value = double.parse(digits) / 100;

      final text = currencyFormat.format(value);

      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    },
  );

  static double parseCurrency(String text) {
    final clean = text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    return double.tryParse(clean) ?? 0.0;
  }
}