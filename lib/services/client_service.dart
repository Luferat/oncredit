// lib/services/client_service.dart

import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/client.dart';

class ClientService {
  final Dio _dio = Dio();

  Future<List<Client>> getClients() async {
    final uid = AppConfig.fixedUid;

    final response = await _dio.get(
      '${AppConfig.baseUrl}/users/$uid/clients.json',
    );

    final data = response.data as Map<String, dynamic>? ?? {};

    return data.entries.map((e) => Client.fromMap(e.key, e.value)).toList();
  }
}