// lib/pages/new_client_page.dart

import 'package:flutter/material.dart';
import 'package:oncredit/templates/appbar.dart';
import '../services/client_service.dart';
import 'client_page.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

final _cpfMask = MaskTextInputFormatter(
  mask: '###.###.###-##',
  filter: {"#": RegExp(r'[0-9]')},
);

final phoneMask11 = MaskTextInputFormatter(
  mask: '(##) #########',
  filter: {'#': RegExp(r'[0-9]')},
);

class NewClientPage extends StatefulWidget {
  const NewClientPage({super.key});

  @override
  State<NewClientPage> createState() => _NewClientPageState();
}

class _NewClientPageState extends State<NewClientPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final List<TextEditingController> _phones = [TextEditingController()];

  final ClientService _clientService = ClientService();

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final cpf = _cpfController.text.replaceAll(RegExp(r'\D'), '');

    final exists = await _clientService.cpfExists(cpf);

    if (exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('CPF já cadastrado')));
      return;
    }

    final phones = _phones
        .map((c) => c.text.replaceAll(RegExp(r'\D'), ''))
        .where((p) => p.isNotEmpty)
        .toList();

    final client = await _clientService.createClient(
      name: _nameController.text.trim(),
      cpf: cpf,
      phones: phones,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ClientPage(client: client)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Text(
                  "Novo cliente",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _cpfController,
                keyboardType: TextInputType.number,
                inputFormatters: [_cpfMask],
                decoration: const InputDecoration(labelText: 'CPF'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o CPF' : null,
              ),

              const SizedBox(height: 25),

              Column(
                children: [
                  ..._phones.map((phone) {
                    final index = _phones.indexOf(phone);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phones[index],
                              keyboardType: TextInputType.phone,
                              inputFormatters: [phoneMask11],
                              decoration: InputDecoration(
                                labelText: 'Telefone ${index + 1}',
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: _phones.length > 1
                                ? () => setState(() => _phones.remove(phone))
                                : null,
                          ),
                        ],
                      ),
                    );
                  }),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar telefone'),
                      onPressed: () {
                        setState(() {
                          _phones.add(TextEditingController());
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, size: 22),
                  label: const Text('Salvar', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
