// lib/models/purchase.dart

class Purchase {
  final String clientId;
  final String description;
  final int quantity;
  final double unitValue;
  final double totalValue;
  final DateTime date;

  Purchase({
    required this.clientId,
    required this.description,
    required this.quantity,
    required this.unitValue,
    required this.totalValue,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'description': description,
      'quantity': quantity,
      'unitValue': unitValue,
      'totalValue': totalValue,
      'date': date.toIso8601String().substring(0, 10),
    };
  }
}