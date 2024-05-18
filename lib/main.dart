import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:web_1/home.dart';
import 'package:web_1/juniorf.dart';
import 'package:web_1/login.dart';

import 'register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        
        useMaterial3: true,
      ),
      home:home(),
      debugShowCheckedModeBanner: false,
    );
    
  }
}
