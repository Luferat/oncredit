// lib/pages/home.dart

import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../models/client.dart';
import '../templates/appbar.dart';
import '../services/finance_service.dart';
import '../services/client_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final String _status;
  final FinanceService _financeService = FinanceService();

  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  get _clientService => null;

  @override
  void initState() {
    super.initState();
    _status = 'UID ativo: ${AppConfig.fixedUid}';
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
          // --- Saldo ---
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

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Saldo total a receber',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'R\$ ${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // --- Busca ---
          _buildSearchField(),

          // --- Lista de clientes ---
          Expanded(
            child: FutureBuilder<List<Client>>(
              future: _clientService.getClients(),
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
                      leading: const Icon(Icons.person),
                      title: Text(client.name),
                      subtitle: Text(client.cpf),
                      onTap: () {
                        // próximo passo: selecionar cliente
                        debugPrint('Selecionou ${client.name}');
                      },
                    );
                  },
                );
              },
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
