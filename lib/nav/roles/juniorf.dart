import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_1/home.dart';
import 'package:web_1/initial.dart';
import 'package:web_1/leaverequest.dart';
import 'package:web_1/nav/leavehistory.dart';



class juniorF extends StatefulWidget {
  const juniorF({super.key});

  @override
  State<juniorF> createState() => _juniorFState();
}

class _juniorFState extends State<juniorF> {
  String? name;
  String? employeeId;
  String? role;
  String? gender;
  String? email;


  @override
  void initState() {
    super.initState();
    _fetchBioInfo();
  }

  Future<void> _fetchBioInfo() async {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      final userId = user.uid;
      final userData = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userData.exists) {
        final data = userData.data();
        if (data != null && data.containsKey('name') && data.containsKey('employeeId') && data.containsKey('imageUrl')) {
          setState(() {
            name = data['name'];
            employeeId = data['employeeId'];
            role = data['role'] ?? 'No role available';
            gender = data['gender'] ?? 'No gender available';
            email = user.email ?? 'No email available';
            
          });
        } else {
          // Redirect to InitialDataForm if data is incomplete
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InitialDataForm()),
          );
        }
      } else {
        // Redirect to InitialDataForm if no data exists
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InitialDataForm()),
        );
      }
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InitialDataForm()),
    );
    if (result == true) {
      _fetchBioInfo();  // Refresh bio info after editing
    }
  }

   final FirebaseAuth auth = FirebaseAuth.instance;

 signOut() async {
    await auth.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => home()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
        
          Positioned(
            top: 250,
            left: 50,
            child: Text(
              name != null ? 'Employee Name: $name' : 'Employee Name: Loading...',
              style: TextStyle(fontSize: 25),
            ),
          ),
        
          Positioned(
            top: 300,
            left: 50,
            child: Text(
              'Employee ID: ${employeeId ?? 'Loading...'}',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Positioned(
            top: 350,
            left: 50,
            child: Text(
              'Role: ${role ?? 'Loading...'}',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Positioned(
            top: 400,
            left: 50,
            child: Text(
              'Gender: ${gender ?? 'Loading...'}',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Positioned(
            top: 450,
            left: 50,
            child: Text(
              'Email: ${email ?? 'Loading...'}',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Positioned(
            top: 480,
            left: 50,
            child: Row(
              children: [
                Icon(Icons.edit),
                TextButton(
                  onPressed: _navigateToEditProfile,
                  child: Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
            Positioned(
            top: 100,
            left: 400,
            child: Row(
              children: [
                Icon(Icons.add_task),
                TextButton(
                  onPressed:() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveRequestForm())),
                  child: Text(
                    'Request Leave',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
            Positioned(
            top: 100,
            left: 600,
            child: Row(
              children: [
                Icon(Icons.history),
                TextButton(
                  onPressed:() =>  Navigator.push(context, MaterialPageRoute(builder: (context) => LeaveHistoryPage())),
                  child: Text(
                    'Leave History',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
            Positioned(
            top: 600,
            left: 100,
            child: Row(
              children: [
                Icon(Icons.logout),
                 
                TextButton(onPressed: () {signOut();}, child: Text('LOGOUT',style: TextStyle(color: Colors.red),))
              ],
            
          ),
            ),
              Positioned(
            top: 180,
            left: 500,
            child:Image.asset('images/junior.png')
            )
              
          
        ],
      ),
    );
  }
}
