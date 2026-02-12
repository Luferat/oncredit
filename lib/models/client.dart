// lib/models/client.dart

class Client {
  final String id;
  final String name;
  final String cpf;
  final List<String> phones;

  Client({
    required this.id,
    required this.name,
    required this.cpf,
    this.phones = const [],
  });

  String get formattedCpf {
    if (cpf.length != 11) return cpf;

    return '${cpf.substring(0, 3)}.'
        '${cpf.substring(3, 6)}.'
        '${cpf.substring(6, 9)}-'
        '${cpf.substring(9, 11)}';
  }

  factory Client.fromMap(String id, Map<String, dynamic> data) {
    return Client(
      id: id,
      name: data['name'],
      cpf: data['cpf'],
      phones: List<String>.from(data['phones'] ?? []),
    );
  }
}