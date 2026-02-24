import 'package:flutter/material.dart';

class GivvApp extends StatelessWidget {
  const GivvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Text('GIVV Architecture Ready'),
        ),
      ),
    );
  }
}