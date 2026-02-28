import 'package:flutter/material.dart';
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
    checkUpdate();
  }

  Future<void> checkUpdate() async {
    final update = await UpdateService.checkForUpdate();

    if (!mounted) return;

    if (update != null) {
      await showDialog(
        context: context,
        barrierDismissible: !update.force,
        builder: (_) => UpdateDialog(update: update),
      );
    }

    Navigator.pushReplacementNamed(context, '/clients');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}