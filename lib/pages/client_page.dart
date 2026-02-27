// lib/pages/client_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/client.dart';
import '../services/client_service.dart';
import '../templates/appbar.dart';
import '../services/finance_service.dart';
import '../theme/theme_extensions.dart';
import '../tools/formatters.dart';
import 'client_edit_page.dart';
import 'client_history_page.dart';
import 'package:flutter/services.dart';


import 'new_payment_page.dart';
import 'new_purchase_page.dart';

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
  late Client _client;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
  }

  @override
  Widget build(BuildContext context) {
    final client = _client;

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
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewPurchasePage(clientId: client.id),
                  ),
                );

                if (result == true) {
                  setState(() {}); // recarrega resumo financeiro
                }
              },
            ),

            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Registrar pagamento'),
              onTap: () async {
                final result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewPaymentPage(clientId: client.id),
                  ),
                );

                if (result == true) {
                  setState(() {}); // atualiza resumo financeiro
                }
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
                  backgroundColor: context.colors.onPrimary,
                  foregroundColor: context.colors.primary,
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
      bottomNavigationBar: SafeArea(child: _buildBottomActions(context),),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    final client = _client;

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
                backgroundColor: context.colors.onPrimary,
                foregroundColor: context.colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit),
              label: const Text('Editar'),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Editar cliente'),
                    content: const Text(
                      'As alterações feitas não poderão ser desfeitas.\n\nDeseja continuar?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Continuar'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  final result = await Navigator.push<ClientEditResult>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientEditPage(client: client),
                    ),
                  );

                  if (!mounted || result == null) return;

                  switch (result) {
                    case ClientEditResult.updated:
                      await _reloadClient();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cliente atualizado com sucesso'),
                        ),
                      );
                      break;

                    case ClientEditResult.deleted:
                      Navigator.pop(context, ClientEditResult.deleted);
                      break;
                  }
                }
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
    final phones = _client.phones;

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

    try {
      switch (action) {
        case 'copy':
          await Clipboard.setData(ClipboardData(text: number));
          break;

        case 'call':
          final uri = Uri(scheme: 'tel', path: number);
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          break;

        case 'whatsapp':
          final uri = Uri.parse('https://wa.me/55$number');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          break;
      }
    } catch (e) {
      debugPrint('Launch error: $e');
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

  Future<void> _reloadClient() async {
    final service = ClientService();
    final clients = await service.getClients();

    final updated = clients.firstWhere(
      (c) => c.id == _client.id,
      orElse: () => _client,
    );

    setState(() {
      _client = updated;
    });
  }
}
