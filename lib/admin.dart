import 'package:flutter/material.dart';

class admin extends StatefulWidget {
  const admin({super.key});

  @override
  State<admin> createState() => _adminState();
}

class _adminState extends State<admin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('admin'),
      ),
    );
  }
}