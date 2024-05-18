import 'package:flutter/material.dart';

class junior extends StatefulWidget {
  const junior({super.key});

  @override
  State<junior> createState() => _juniorState();
}

class _juniorState extends State<junior> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('junior'),),
    );
  }
}