// lib/services/finance_service.dart

import 'package:dio/dio.dart';
import '../config/app_config.dart';

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
}
