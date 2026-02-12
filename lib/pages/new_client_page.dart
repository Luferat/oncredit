// lib/pages/new_client_page.dart

import 'package:flutter/material.dart';
import 'package:oncredit/templates/appbar.dart';
import '../widgets/client_form.dart';
import '../services/client_service.dart';

class NewClientPage extends StatefulWidget {
  const NewClientPage({super.key});

  @override
  State<NewClientPage> createState() => _NewClientPageState();
}

class _NewClientPageState extends State<NewClientPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final List<TextEditingController> _phones = [];

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

    await ClientService().createClient(
      name: _nameController.text,
      cpf: _cpfController.text.replaceAll(RegExp(r'[^0-9]'), ''),
      phones: _phones.map((c) => c.text).toList(),
    );

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
              'Cadastro de Cliente',
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
              cpfEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}