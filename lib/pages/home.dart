// lib/pages/home.dart

import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/client_service.dart';
import '../templates/appbar.dart';
import '../config/app_config.dart';
import '../tools/formatters.dart';
import '../services/finance_service.dart';
import 'client_edit_page.dart';
import 'client_page.dart';
import 'new_client_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final String _status;
  late Future<List<Client>> _clientsFuture;

  final FinanceService _financeService = FinanceService();
  final ClientService _clientService = ClientService();

  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  void _reloadClients() {
    setState(() {
      _clientsFuture = _clientService.getClients();
    });
  }

  @override
  void initState() {
    super.initState();
    _status = 'UID ativo: ${AppConfig.fixedUid}';
    _clientsFuture = _clientService.getClients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            heightFactor: 1,
            child: Padding(
              padding: EdgeInsetsGeometry.all(5),
              child: Text(_status, style: const TextStyle(fontSize: 14)),
            ),
          ),

          FutureBuilder<double>(
            future: _financeService.getTotalBalance(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              final balance = snapshot.data!;

              return Card(
                margin: const EdgeInsets.all(16),
                color: Colors.deepPurple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Saldo total a receber',
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.currencyFormat.format(balance),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 8),

          _buildSearchField(),

          const SizedBox(height: 8),

          Expanded(
            child: FutureBuilder<List<Client>>(
              future: _clientsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final clients = snapshot.data!
                    .where((c) => c.name.toLowerCase().contains(_search))
                    .toList();

                if (clients.isEmpty) {
                  return const Center(child: Text('Nenhum cliente encontrado'));
                }

                return ListView.builder(
                  itemCount: clients.length,
                  itemBuilder: (context, index) {
                    final client = clients[index];

                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      contentPadding: const EdgeInsets.only(left: 40.0),
                      title: Text(client.name),
                      subtitle: Text('CPF: ${client.formattedCpf}'),
                      onTap: () async {
                        final result = await Navigator.push<ClientEditResult>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClientPage(client: client),
                          ),
                        );

                        if (result == ClientEditResult.deleted) {
                          _reloadClients();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Cliente apagado com sucesso'),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add, size: 22),
                label: const Text(
                  'Novo cliente',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () async {
                  final created = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewClientPage()),
                  );

                  setState(() {
                    _clientsFuture = _clientService.getClients();
                  });

                  if (created == true) {
                    setState(() {});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Pesquisar cliente...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() {
                _search = '';
              });
            },
          )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _search = value.toLowerCase();
          });
        },
      ),
    );
  }
}