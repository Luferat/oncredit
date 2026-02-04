// lib/tools/formatters.dart

import 'package:intl/intl.dart';

class Formatters {
  static final dateFormat = DateFormat('dd/MM/yyyy');
  static final currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );
}