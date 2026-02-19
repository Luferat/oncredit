// lib/models/financial_event.dart

enum FinancialEventType { purchase, payment }

class FinancialEvent {
  final String description;
  final double value;
  final DateTime date;
  final FinancialEventType type;
  final String? method;

  FinancialEvent({
    required this.description,
    required this.value,
    required this.date,
    required this.type,
    this.method,
  });
}