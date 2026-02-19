// lib/models/payment.dart

class Payment {
  final String clientId;
  final double value;
  final String method;
  final DateTime date;

  Payment({
    required this.clientId,
    required this.value,
    required this.method,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'value': value,
      'method': method,
      'date': date.toIso8601String().substring(0, 10),
    };
  }
}