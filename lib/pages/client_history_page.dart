// lib/pages/client_history_page.dart

import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/financial_event.dart';
import '../services/finance_service.dart';
import '../templates/appbar.dart';

import '../tools/formatters.dart';

class ClientHistoryPage extends StatelessWidget {
  final Client client;

  const ClientHistoryPage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'Histórico de Relacionamento',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 22),

            // --- Identificação do cliente (igual ClientPage) ---
            Text(
              client.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('CPF: ${client.cpf}'),
            const SizedBox(height: 16),
            const Divider(),

            // --- Histórico ---
            Expanded(
              child: FutureBuilder<List<FinancialEvent>>(
                future: FinanceService().getClientHistory(client.id),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final history = snapshot.data!;

                  if (history.isEmpty) {
                    return const Center(
                      child: Text('Nenhum registro encontrado'),
                    );
                  }

                  return ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      final isPurchase =
                          item.type == FinancialEventType.purchase;

                      return ListTile(
                        leading: Icon(
                          isPurchase ? Icons.shopping_cart : Icons.payments,
                          color: isPurchase ? Colors.red : Colors.green,
                        ),
                        title: Text(item.description),
                        subtitle: Text(Formatters.dateFormat.format(item.date)),
                        trailing: Text(
                          '${isPurchase ? '- ' : '+ '}${Formatters.currencyFormat.format(item.value)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isPurchase ? Colors.red : Colors.green,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

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
                  margin: const EdgeInsets.only(top: 16),
                  color: Colors.deepPurple.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Resumo do período',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _summaryLine('Total em compras', summary['purchases']!),
                        _summaryLine('Total pago', summary['payments']!),
                        const Divider(),
                        _summaryLine(
                          'Débito atual',
                          summary['balance']!,
                          bold: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryLine(String label, double value, {bool bold = false}) {
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
}
