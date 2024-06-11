import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_1/employeelist.dart';
import 'package:web_1/home.dart';
import 'package:web_1/leaverequest.dart';
import 'package:web_1/leaverequestservice.dart';
import 'package:web_1/login.dart';
import 'package:web_1/nav/roles/admin.dart';

class admin1 extends StatefulWidget {
  const admin1({super.key});

  @override
  State<admin1> createState() => _admin1State();
}

class _admin1State extends State<admin1> {
 final FirebaseAuth auth = FirebaseAuth.instance;

 signOut() async {
    await auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => home()));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [ Center(
        child: Column(
          children: [
            SizedBox(height: 50,),
            Image.asset('images/logo.png'),
            SizedBox(height: 30,),
TextButton(onPressed:() => Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveRequests(),)), child: Text('LEAVE REQUESTS',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.w600),)),
SizedBox(height: 15,),
TextButton(onPressed:() => Navigator.push(context, MaterialPageRoute(builder: (context) => admin(),)), child: Text('PROFILE EDITS',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.w600),)),
SizedBox(height:15),
TextButton(onPressed:() => Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeListPage())), child: Text('EMPLOYEES',style: TextStyle(fontSize: 20,color: Colors.black,fontWeight: FontWeight.w600),)),
 
          ],
        ),),
          Positioned(
            top: 600,
            left: 100,
            child: Row(
              children: [
                Icon(Icons.logout),
                 
                TextButton(onPressed: () {signOut();}, child: Text('LOGOUT',style: TextStyle(color: Colors.red),))
              ],
            
          ),)
          ],)
      );
  }
}