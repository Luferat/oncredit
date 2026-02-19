// lib/pages/new_purchase_page.dart

import 'package:flutter/material.dart';
import 'package:oncredit/templates/appbar.dart';
import '../models/purchase.dart';
import '../services/finance_service.dart';
import '../tools/formatters.dart';

class NewPurchasePage extends StatefulWidget {
  final String clientId;

  const NewPurchasePage({super.key, required this.clientId});

  @override
  State<NewPurchasePage> createState() => _NewPurchasePageState();
}

class _NewPurchasePageState extends State<NewPurchasePage> {
  final _formKey = GlobalKey<FormState>();

  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitValueController = TextEditingController();

  DateTime _date = DateTime.now();
  double _totalValue = 0.0;
  bool _saving = false;

  void _recalculateTotal() {
    final quantity = int.tryParse(_quantityController.text) ?? 0;
    final unit = Formatters.parseCurrency(_unitValueController.text);

    setState(() {
      _totalValue = quantity * unit;
    });
  }

  Future<void> _pickDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (result != null) {
      setState(() => _date = result);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final quantity = int.parse(_quantityController.text);
    final unitValue = Formatters.parseCurrency(_unitValueController.text);

    final purchase = Purchase(
      clientId: widget.clientId,
      description: _descriptionController.text.trim(),
      quantity: quantity,
      unitValue: unitValue,
      totalValue: quantity * unitValue,
      date: _date,
    );

    await FinanceService().registerPurchase(purchase);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Registrar compra',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _descriptionController,
                    decoration:
                    const InputDecoration(labelText: 'Descrição'),
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a descrição' : null,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration:
                          const InputDecoration(labelText: 'Quantidade'),
                          onChanged: (_) => _recalculateTotal(),
                          validator: (v) {
                            final q = int.tryParse(v ?? '');
                            return q == null || q <= 0
                                ? 'Quantidade inválida'
                                : null;
                          },
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: TextFormField(
                          controller: _unitValueController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [Formatters.currencyInput],
                          decoration: const InputDecoration(
                            labelText: 'Valor unitário',
                          ),
                          onChanged: (_) => _recalculateTotal(),
                          validator: (v) =>
                          v == null || v.isEmpty ? 'Informe o valor' : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: Text(
                      Formatters.dateFormat.format(_date),
                    ),
                    onTap: _pickDate,
                  ),

                  const Divider(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(fontSize: 18),
                      ),
                      Text(
                        Formatters.currencyFormat.format(_totalValue),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Salvar compra',
                        style: TextStyle(fontSize: 18),
                      ),
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}