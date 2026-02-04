// lib/pages/home.dart

import 'package:flutter/material.dart';
import '../templates/appbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final String _status;

  @override
  void initState() {
    super.initState();
    _status = 'UID ativo: dev_uid_001';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(),
      body: Center(
        child: Text(
          _status,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
