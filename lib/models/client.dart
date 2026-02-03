// lib/models/client.dart

class Client {
  final String id;
  final String name;
  final String cpf;

  Client({
    required this.id,
    required this.name,
    required this.cpf
  });

  factory Client.fromMap(String id, Map<String, dynamic> data) {
    return Client(id: id, name: data['name'] ?? '', cpf: data['cpf'] ?? '');
  }
}