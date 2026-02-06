// lib/pages/client_page.dart

import 'package:flutter/material.dart';
import '../models/client.dart';
import '../templates/appbar.dart';
import '../services/finance_service.dart';
import '../tools/formatters.dart';
import 'client_history_page.dart';

class ClientPage extends StatelessWidget {
  final Client client;

  const ClientPage({super.key, required this.client});

  Widget _line(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            Formatters.currencyFormat.format(value),
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              client.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('CPF: ${client.cpf}'),
            const SizedBox(height: 16),

            // Aqui depois entra o resumo financeiro do cliente
            const Divider(),

            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Registrar compra'),
              onTap: () {
                // navegar para PurchasePage
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Registrar pagamento'),
              onTap: () {
                // navegar para PaymentPage
              },
            ),

            const SizedBox(height: 16),
            const Divider(),

            FutureBuilder<Map<String, double>>(
              future: FinanceService().getClientSummary(client.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }

                final summary = snapshot.data!;

                return Card(
                  margin: const EdgeInsets.only(top: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumo financeiro',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _line('Total em compras', summary['purchases']!),
                        _line('Total pago', summary['payments']!),
                        const Divider(),
                        _line('Débito atual', summary['balance']!, bold: true),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add, size: 22),
                label: const Text(
                  'Ver histórico completo',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientHistoryPage(client: client),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
