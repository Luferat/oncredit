// lib/services/finance_service.dart

import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/financial_event.dart';

class FinanceService {
  final Dio _dio = Dio();

  Future<double> getTotalBalance() async {
    final uid = AppConfig.fixedUid;

    final purchasesResponse = await _dio.get(
      '${AppConfig.baseUrl}/users/$uid/purchases.json',
    );

    final paymentsResponse = await _dio.get(
      '${AppConfig.baseUrl}/users/$uid/payments.json',
    );

    double totalPurchases = 0;
    double totalPayments = 0;

    final purchases = purchasesResponse.data as Map<String, dynamic>? ?? {};
    final payments = paymentsResponse.data as Map<String, dynamic>? ?? {};

    for (final p in purchases.values) {
      totalPurchases += (p['totalValue'] as num).toDouble();
    }

    for (final p in payments.values) {
      totalPayments += (p['value'] as num).toDouble();
    }

    return totalPurchases - totalPayments;
  }

  Future<Map<String, double>> getClientSummary(String clientId) async {
    final uid = AppConfig.fixedUid;

    final purchasesResponse = await _dio.get(
      '${AppConfig.baseUrl}/users/$uid/purchases.json',
    );

    final paymentsResponse = await _dio.get(
      '${AppConfig.baseUrl}/users/$uid/payments.json',
    );

    double totalPurchases = 0;
    double totalPayments = 0;

    final purchases = purchasesResponse.data as Map<String, dynamic>? ?? {};
    final payments = paymentsResponse.data as Map<String, dynamic>? ?? {};

    for (final p in purchases.values) {
      if (p['clientId'] == clientId) {
        totalPurchases += (p['totalValue'] as num).toDouble();
      }
    }

    for (final p in payments.values) {
      if (p['clientId'] == clientId) {
        totalPayments += (p['value'] as num).toDouble();
      }
    }

    return {
      'purchases': totalPurchases,
      'payments': totalPayments,
      'balance': totalPurchases - totalPayments,
    };
  }

  Future<List<FinancialEvent>> getClientHistory(String clientId) async {
    final uid = AppConfig.fixedUid;

    final purchasesResponse = await _dio.get(
      '${AppConfig.baseUrl}/users/$uid/purchases.json',
    );

    final paymentsResponse = await _dio.get(
      '${AppConfig.baseUrl}/users/$uid/payments.json',
    );

    final List<FinancialEvent> history = [];

    final purchases = purchasesResponse.data as Map<String, dynamic>? ?? {};
    final payments = paymentsResponse.data as Map<String, dynamic>? ?? {};

    for (final p in purchases.values) {
      if (p['clientId'] == clientId) {
        history.add(
          FinancialEvent(
            description: 'Compra',
            value: (p['totalValue'] as num).toDouble(),
            date: DateTime.parse(p['date']),
            type: FinancialEventType.purchase,
          ),
        );
      }
    }

    for (final p in payments.values) {
      if (p['clientId'] == clientId) {
        history.add(
          FinancialEvent(
            description: 'Pagamento',
            value: (p['value'] as num).toDouble(),
            date: DateTime.parse(p['date']),
            type: FinancialEventType.payment,
          ),
        );
      }
    }

    history.sort((a, b) => b.date.compareTo(a.date)); // mais recente primeiro

    return history;
  }
}
