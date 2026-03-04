// lib/pages/home.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import '../services/biometric_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();
    _startup();
  }

  Future<void> _startup() async {
    // 1. Verifica se o UID já está configurado
    final hasUid = await AppConfig.hasUid();

    if (!mounted) return;

    if (!hasUid) {
      final configured = await _requestUid();
      if (!configured) {
        // Usuário cancelou ou falhou — fecha o app
        SystemNavigator.pop();
        return;
      }
    }

    if (!mounted) return;

    // 2. Verifica biometria
    final biometricEnabled = await BiometricService.isEnabled();

    if (biometricEnabled) {
      setState(() => _showBiometric = true);
      final authenticated = await BiometricService.authenticate();
      if (!mounted) return;

      if (!authenticated) {
        SystemNavigator.pop();
        return;
      }

      setState(() => _showBiometric = false);
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/clients');
  }

  Future<bool> _requestUid() async {

    // Busca o Android ID antes de abrir o dialog
    final deviceId = await AppConfig.getDeviceId();

    // Controllers já preenchidos com os valores default de AppConfig
    final uidController = TextEditingController(text: deviceId);
    final urlController = TextEditingController(text: AppConfig.baseUrl);
    String? errorText;
    bool confirmed = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Bem-vindo ao ONCredit'),
              content: SingleChildScrollView(
                // ← evita overflow em telas pequenas
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Para começar, configure o acesso ao banco de dados.\n\n'
                      'Em caso de dúvidas, contacte o administrador do sistema.',
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: uidController,
                      decoration: InputDecoration(
                        labelText: 'UID',
                        border: const OutlineInputBorder(),
                        errorText: errorText,
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'Base URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final uid = uidController.text.trim();
                    final url = urlController.text.trim().replaceAll(RegExp(r'/+$'), '');

                    if (uid.isEmpty) {
                      setDialogState(() => errorText = 'Informe o UID');
                      return;
                    }

                    setDialogState(() => errorText = null);

                    // Valida usando a URL informada no formulário
                    final valid = await AppConfig.validateUid(
                      uid,
                      customUrl: url,
                    );

                    if (!valid) {
                      setDialogState(
                        () => errorText = 'UID inválido ou sem conexão',
                      );
                      return;
                    }

                    await AppConfig.save(uid, url); // ← salva ambos
                    confirmed = true;
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Confirmar'),
                ),
              ],
            );
          },
        );
      },
    );

    return confirmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'ON',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    fontSize: 42,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.credit_score, color: Colors.white, size: 50),
                SizedBox(width: 4),
                Text(
                  'Credit',
                  style: TextStyle(color: Colors.white, fontSize: 36),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // Ícone de biometria ou spinner
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _showBiometric
                  ? const Icon(
                      Icons.fingerprint,
                      key: ValueKey('fingerprint'),
                      size: 72,
                      color: Colors.orange,
                    )
                  : const SizedBox(
                      key: ValueKey('spinner'),
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        color: Colors.orange,
                        strokeWidth: 3,
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // Texto de status
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _showBiometric ? 'Confirme sua identidade' : 'Aguarde...',
                key: ValueKey(_showBiometric),
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
