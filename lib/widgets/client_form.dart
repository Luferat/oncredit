// lib/widgets/client_form.dart

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class ClientForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;

  final TextEditingController nameController;
  final TextEditingController cpfController;
  final List<TextEditingController> phoneControllers;

  final VoidCallback onAddPhone;
  final void Function(int index) onRemovePhone;
  final VoidCallback onSave;

  final bool cpfEnabled;

  ClientForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.cpfController,
    required this.phoneControllers,
    required this.onAddPhone,
    required this.onRemovePhone,
    required this.onSave,
    this.cpfEnabled = true,
  });

  final _cpfMask = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  final _phoneMask = MaskTextInputFormatter(
    mask: '(##) #########',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Nome'),
            validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
          ),

          const SizedBox(height: 12),

          TextFormField(
            controller: cpfController,
            enabled: cpfEnabled,
            decoration: InputDecoration(
              labelText: 'CPF',
              helperText: cpfEnabled ? null : 'CPF não pode ser alterado',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [_cpfMask],
            validator: (v) {
              if (!cpfEnabled) return null;
              return v == null || v.isEmpty ? 'Informe o CPF' : null;
            },
          ),

          const SizedBox(height: 16),

          const Text(
            'Telefones',
            style: TextStyle(fontSize: 18, color: Colors.black54),
          ),

          const SizedBox(height: 8),

          ..._buildPhones(),

          TextButton.icon(
            onPressed: onAddPhone,
            icon: const Icon(Icons.add),
            label: const Text('Adicionar telefone'),
          ),

          const SizedBox(height: 18),

          ElevatedButton.icon(
            icon: Icon(Icons.save),
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
            label: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPhones() {
    return List.generate(phoneControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: phoneControllers[index],
                decoration: const InputDecoration(labelText: 'Telefone com DDD'),
                keyboardType: TextInputType.number,
                inputFormatters: [_phoneMask],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => onRemovePhone(index),
            ),
          ],
        ),
      );
    });
  }
}