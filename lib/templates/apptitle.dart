// lib/templates/apptitle.dart

import 'package:flutter/material.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ON',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.orange,
            fontSize: 25,
          ),
        ),
        SizedBox(width: 2),
        Icon(Icons.credit_score, color: Colors.white, size: 30),
        SizedBox(width: 2),
        Text('Credit', style: TextStyle(color: Colors.white, fontSize: 20)),
      ],
    );
  }
}
