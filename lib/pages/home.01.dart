// lib/pages/home.dart

import 'package:flutter/material.dart';
import '../templates/appbar.dart';
import '../config/app_config.dart';
import '../tools/formatters.dart';
import '../services/finance_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final String _status;

  final FinanceService _financeService = FinanceService();

  @override
  void initState() {
    super.initState();
    _status = 'UID ativo: ${AppConfig.fixedUid}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Column(
        children: [
          // OPCIONAL: Identificação da base de dados (Uid)
          Align(
            alignment: Alignment.centerRight,
            heightFactor: 1,
            child: Padding(
              padding: EdgeInsetsGeometry.all(5),
              child: Text(_status, style: const TextStyle(fontSize: 14)),
            ),
          ),

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
        ],
      ),
    );
  }
}
