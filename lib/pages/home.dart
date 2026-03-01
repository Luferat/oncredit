// lib/pages/home.dart

import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _startup();
  }

  Future<void> _startup() async {
    // 1. Verifica atualização
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

    // 2. Verifica biometria
    final biometricEnabled = await BiometricService.isEnabled();

    if (biometricEnabled) {
      final authenticated = await BiometricService.authenticate();

      if (!mounted) return;

      if (!authenticated) {
        // Falhou ou cancelou — fecha o app
        Navigator.pushReplacementNamed(context, '/');
        return;
      }
    }

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/clients');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
