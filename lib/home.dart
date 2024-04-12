import 'package:flutter/material.dart';
import 'package:web_1/login.dart';

class home extends StatefulWidget {
  const home({super.key});

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
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
        login()
      ],
      )
    );
  }
}