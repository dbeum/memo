import 'package:flutter/material.dart';
import 'package:web_1/employeelist.dart';
import 'package:web_1/leaverequest.dart';
import 'package:web_1/leaverequestservice.dart';
import 'package:web_1/nav/roles/admin.dart';

class admin1 extends StatefulWidget {
  const admin1({super.key});

  @override
  State<admin1> createState() => _admin1State();
}

class _admin1State extends State<admin1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
TextButton(onPressed:() => Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveRequests(),)), child: Text('leave')),
SizedBox(height: 10,),
TextButton(onPressed:() => Navigator.push(context, MaterialPageRoute(builder: (context) => admin(),)), child: Text('profile')),
SizedBox(height:10),
TextButton(onPressed:() => Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeListPage())), child: Text('Employees'))
          ],
        ),),
      );
  }
}