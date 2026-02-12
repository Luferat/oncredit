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

  Future<Client> createClient({
    required String name,
    required String cpf,
    required List<String> phones,
  }) async {
    final uid = AppConfig.fixedUid;

    final response = await _dio.post(
      '${AppConfig.baseUrl}/users/$uid/clients.json',
      data: {
        'name': name,
        'cpf': cpf,
        'phones': phones,
        'createdAt': DateTime.now().toIso8601String().substring(0, 10),
      },
    );

    final generatedId = response.data['name'];

    return Client(id: generatedId, name: name, cpf: cpf);
  }

  Future<bool> cpfExists(String cpf) async {
    final uid = AppConfig.fixedUid;

    final response = await _dio.get(
      '${AppConfig.baseUrl}/users/$uid/clients.json',
    );

    final data = response.data as Map<String, dynamic>? ?? {};

    return data.values.any((c) => c['cpf'] == cpf);
  }
}
