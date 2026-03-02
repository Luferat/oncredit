// lib/pages/home.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/biometric_service.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';

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
    final update = await UpdateService.checkForUpdate();
    if (!mounted) return;
    if (update != null) {
      await showDialog(
        context: context,
        barrierDismissible: !update.force,
        builder: (_) => UpdateDialog(update: update),
      );
    }

    if (!mounted) return;
    final biometricEnabled = await BiometricService.isEnabled();

    if (biometricEnabled) {
      setState(() => _showBiometric = true);
      final authenticated = await BiometricService.authenticate();
      if (!mounted) return;

      if (!authenticated) {
        SystemNavigator.pop();
        return;
      }

      setState(() => _showBiometric = false); // ← volta ao spinner após autenticar
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/clients');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade900,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // Logo — replica o AppTitle mas maior e sem interação
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
                _showBiometric
                    ? 'Confirme sua identidade'
                    : 'Aguarde...',
                key: ValueKey(_showBiometric),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}