import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:web_1/initial.dart';

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
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    _fetchBioInfo();
  }

 Future<void> _fetchBioInfo() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final userId = user.uid;
    final userData = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (userData.exists) {
      final data = userData.data();
      if (data != null && data.containsKey('name') && data.containsKey('employeeId')) {
        setState(() {
          name = data['name'];
          employeeId = data['employeeId'];
          role = data['role'] ?? 'No role available';
          gender = data['gender'] ?? 'No gender available';
          email = user.email ?? 'No email available';
          imageUrl = data['imageUrl'];
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InitialDataForm()),
        );
      }
    }
  }
}


 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (imageUrl != null)
            Positioned(
              top: 50,
              left: 220,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(imageUrl!),
                onBackgroundImageError: (exception, stackTrace) {
                  setState(() {
                    imageUrl = null;
                  });
                },
              ),
            )
          else
            Positioned(
              top: 50,
              left: 220,
              child: CircleAvatar(
                radius: 50,
                child: Icon(Icons.person),
              ),
            ),
          Positioned(
            top: 150,
            left: 220,
            child: Text(
              name != null ? 'Employee Name: $name' : 'Employee Name: Loading...',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Positioned(
            top: 200,
            left: 50,
            child: Text(
              'Name: ${name ?? 'Loading...'}',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Positioned(
            top: 250,
            left: 50,
            child: Text(
              'Employee ID: ${employeeId ?? 'Loading...'}',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Positioned(
            top: 300,
            left: 50,
            child: Text(
              'Role: ${role ?? 'Loading...'}',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Positioned(
            top: 350,
            left: 50,
            child: Text(
              'Gender: ${gender ?? 'Loading...'}',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Positioned(
            top: 400,
            left: 50,
            child: Text(
              'Email: ${email ?? 'Loading...'}',
              style: TextStyle(fontSize: 25),
            ),
          ),
          Positioned(
            top: 200,
            left: 900,
            child: Row(
              children: [
                Icon(Icons.edit),
                TextButton(
                  onPressed:() {
                    
                  } ,
                  child: Text(
                    'Request For Leave',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}