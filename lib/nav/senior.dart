import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_1/editprofile.dart';

class senior extends StatefulWidget {
  const senior({super.key});

  @override
  State<senior> createState() => _seniorState();
}

class _seniorState extends State<senior> {
  String? bioInfo;

  @override
  void initState() {
    super.initState();
    // Fetch bio information from Firestore
    _fetchBioInfo();
  }

  Future<void> _fetchBioInfo() async {
    final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user ID
    if (userId != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        bioInfo = userDoc.data()?['bio'] ?? 'No bio information available';
      });
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );
    if (result == true) {
      _fetchBioInfo();  // Refresh bio info after editing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
      children: [
      
  Positioned(
    top: 50,
    left: 220,
    child: 
  Text('employee name',style: TextStyle(fontSize: 25),)
  ),
  Positioned(
    top:200,
    left: 50,
    child: 
  Text('Name',style: TextStyle(fontSize: 25),)),
    Positioned(
    top:250,
    left: 50,
    child: 
  Text('Role',style: TextStyle(fontSize: 25),)),
  Positioned(
    top:300,
    left: 50,
    child: 
  Text('Gender',style: TextStyle(fontSize: 25),)),
  Positioned(
    top:350,
    left: 50,
    child: 
  Text('Email Address',style: TextStyle(fontSize: 25),))

      ],  
      )
    //  Center(
      //  child: Row(
    //      children: [
  //          Icon(Icons.edit),
        //    TextButton(
      //        onPressed: _navigateToEditProfile,
    //          child: Text(bioInfo ?? 'Edit Profile'),
            //),
  //        ],
       // ),
     // ),
    );
  }
}
