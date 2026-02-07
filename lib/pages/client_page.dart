// lib/pages/client_page.dart

import 'package:flutter/material.dart';
import '../models/client.dart';
import '../templates/appbar.dart';
import '../services/finance_service.dart';
import '../tools/formatters.dart';
import 'client_history_page.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

String onlyNumbers(String value) {
  return value.replaceAll(RegExp(r'[^0-9]'), '');
}

class ClientPage extends StatefulWidget {
  final Client client;

  const ClientPage({super.key, required this.client});

  @override
  State<ClientPage> createState() => _ClientPageState();
}

class _ClientPageState extends State<ClientPage> {
  @override
  Widget build(BuildContext context) {
    final client = widget.client; // 👈 atalho elegante

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
            Text('CPF: ${client.formattedCpf}'),
            const SizedBox(height: 16),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Registrar compra'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Registrar pagamento'),
              onTap: () {},
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
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final client = widget.client;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.call),
              label: const Text('Contatos'),
              onPressed: client.phones.isEmpty
                  ? null
                  : _showContactsBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
              onPressed: () {
                debugPrint('Mostrar popup de confirmação');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactsBottomSheet() {
    final phones = widget.client.phones;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final screenWidth = MediaQuery.of(context).size.width;
        final maxWidth = screenWidth * 0.9;

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth > 500 ? 500 : maxWidth,
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // indicador visual (UX 💎)
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),

                  const Text(
                    'Contatos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 12),

                  ...phones.map((phone) {
                    return ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(phone),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) => _handlePhoneAction(value, phone),
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                            value: 'copy',
                            child: Text('Copiar número'),
                          ),
                          PopupMenuItem(value: 'call', child: Text('Ligar')),
                          PopupMenuItem(
                            value: 'whatsapp',
                            child: Text('WhatsApp'),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handlePhoneAction(String action, String phone) async {
    final number = onlyNumbers(phone);

    switch (action) {
      case 'copy':
        await Clipboard.setData(ClipboardData(text: number));
        break;

      case 'call':
        final uri = Uri.parse('tel:$number');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
        break;

      case 'whatsapp':
        final uri = Uri.parse('https://wa.me/55$number');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        break;
    }
  }
}

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
