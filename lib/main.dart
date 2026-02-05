// lib\main.dart

import 'package:flutter/material.dart';
import 'package:oncredit/pages/home.dart';
import 'package:oncredit/pages/settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OnCredit',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/',

      routes: {
        // Página inicial
        '/': (context) => const HomePage(),
        // Configurações
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
