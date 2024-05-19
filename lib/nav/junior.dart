import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web_1/editprofile.dart';

class junior extends StatefulWidget {
  const junior({super.key});

  @override
  State<junior> createState() => _juniorState();
}

class _juniorState extends State<junior> {
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
      body: Center(
        child: Row(
          children: [
            Icon(Icons.edit),
            TextButton(
              onPressed: _navigateToEditProfile,
              child: Text(bioInfo ?? 'Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
