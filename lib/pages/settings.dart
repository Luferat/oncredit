// lib/pages/settings.dart

import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/client_service.dart';
import '../templates/appbar.dart';
import '../config/app_config.dart';
import '../tools/formatters.dart';
import '../services/finance_service.dart';
import 'client_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final String _status;

  final FinanceService _financeService = FinanceService();
  final ClientService _clientService = ClientService();

  final TextEditingController _searchController = TextEditingController();
  String _search = '';

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
          Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Center(
              child: Text(
                'Configurações do Aplicativo',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
