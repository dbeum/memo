import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_1/editprofile.dart';


class juniorF extends StatefulWidget {
  const juniorF({super.key});

  @override
  State<juniorF> createState() => _juniorFState();
}

class _juniorFState extends State<juniorF> {
  bool _isProfileComplete = false;
  String _name = '';
  String _age = '';

  @override
  void initState() {
    super.initState();
    _checkProfile();
  }

  Future<void> _checkProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc['profileComplete'] == true) {
        setState(() {
          _isProfileComplete = true;
          _name = doc['name'];
          _age = doc['age'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isProfileComplete
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Name: $_name', style: TextStyle(fontSize: 20)),
                  Text('Age: $_age', style: TextStyle(fontSize: 20)),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit, size: 50),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfile()),
                      ).then((value) => _checkProfile()); // Re-check profile on return
                    },
                    child: Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
      ),
    );
  }
}
