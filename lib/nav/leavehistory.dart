import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

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
              final leaveType = request['leaveType'];
              final reason = request['reason'];
              final status = request['status'];
              final timestamp = (request['timestamp'] as Timestamp).toDate();
              final startDate = (request['startDate'] as Timestamp).toDate();
              final endDate = (request['endDate'] as Timestamp).toDate();

              final formattedTimestamp = DateFormat.yMMMd().add_jm().format(timestamp);
              final formattedStartDate = DateFormat.yMMMd().format(startDate);
              final formattedEndDate = DateFormat.yMMMd().format(endDate);

              return ListTile(
                title: Text(leaveType),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reason: $reason'),
                    Text('Application Date: $formattedTimestamp'),
                    Text('Duration: $formattedStartDate - $formattedEndDate'),
                  ],
                ),
                trailing: Text(status),
              );
            },
          );
        },
      ),
    );
  }
}
