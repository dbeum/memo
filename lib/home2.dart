import 'package:flutter/material.dart';
import 'package:web_1/login.dart';
import 'package:web_1/register.dart';

class home2 extends StatefulWidget {
  const home2({super.key});

  @override
  State<home2> createState() => _home2State();
}

class _home2State extends State<home2> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body:Stack(
      children: [
        Container(
            decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage('images/admin.jpg'),
        fit: BoxFit.cover
          )
        ),
        child:   Container(
            color: Colors.black.withOpacity(0.3),
                    ),
         
        ),
        register()
        
      ],
      )
    );
  }
}