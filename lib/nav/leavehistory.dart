import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaveHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Handle if user is not logged in
      return Scaffold(
        body: Center(
          child: Text('User not logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Leave History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leave_requests')
            .where('userId', isEqualTo: user.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error fetching data: ${snapshot.error.toString()}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No leave history available.'));
          }

          final leaveRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: leaveRequests.length,
            itemBuilder: (context, index) {
              final request = leaveRequests[index];
              return ListTile(
                title: Text(request['leaveType']),
                subtitle: Text(request['reason']),
                trailing: Text(request['status']),
                // Add more details as needed
              );
            },
          );
        },
      ),
    );
  }
}
