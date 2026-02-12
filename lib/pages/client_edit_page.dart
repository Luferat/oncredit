// lib/pages/client_edit_page.dart

import 'package:flutter/material.dart';
import 'package:oncredit/templates/appbar.dart';
import '../models/client.dart';
import '../services/client_service.dart';
import '../widgets/client_form.dart';
import 'client_page.dart';

class ClientEditPage extends StatefulWidget {
  final Client client;

  const ClientEditPage({super.key, required this.client});

  @override
  State<ClientEditPage> createState() => _ClientEditPageState();
}

class _ClientEditPageState extends State<ClientEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _cpfController;
  late List<TextEditingController> _phones;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.client.name);
    _cpfController = TextEditingController(text: widget.client.formattedCpf);
    _phones = widget.client.phones
        .map((p) => TextEditingController(text: p))
        .toList();
  }

  void _addPhone() {
    setState(() {
      _phones.add(TextEditingController());
    });
  }

  void _removePhone(int index) {
    setState(() {
      _phones.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final service = ClientService();

    final phones = _phones
        .map((c) => c.text.trim())
        .where((p) => p.isNotEmpty)
        .map(onlyNumbers)
        .toList();

    await service.updateClient(
      id: widget.client.id,
      name: _nameController.text.trim(),
      phones: phones,
    );

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
              'Editar Cliente',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ClientForm(
              formKey: _formKey,
              nameController: _nameController,
              cpfController: _cpfController,
              phoneControllers: _phones,
              onAddPhone: _addPhone,
              onRemovePhone: _removePhone,
              onSave: _save,
              cpfEnabled: false,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('Apagar Cliente'),
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}