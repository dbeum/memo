import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeDetailPage extends StatelessWidget {
  final String userId;

  EmployeeDetailPage({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data!.data() as Map<String, dynamic>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(user['name']),
                subtitle: Text('Employee ID: ${user['employeeId']}'),
              ),
              ListTile(
                title: Text('Gender'),
                subtitle: Text(user['gender']),
              ),
              ListTile(
                title: Text('Role'),
                subtitle: Text(user['role']),
              ),
              SizedBox(height: 10,),
              Text('LEAVE HISTORY',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              Expanded(
                child: LeaveHistory(userId: userId),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LeaveHistory extends StatelessWidget {
  final String userId;

  LeaveHistory({required this.userId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('leave_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final leaveRequests = snapshot.data!.docs;

        if (leaveRequests.isEmpty) {
          return Center(child: Text('No leave requests found.'));
        }

        return ListView.builder(
          itemCount: leaveRequests.length,
          itemBuilder: (context, index) {
            final leaveRequest = leaveRequests[index];
            return ListTile(
              title: Text('Leave Type: ${leaveRequest['leaveType']}'),
              subtitle: Text('Status: ${leaveRequest['status']}'),
              trailing: leaveRequest['timestamp'] != null
                  ? Text(
                      (leaveRequest['timestamp'] as Timestamp)
                          .toDate()
                          .toString(),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
}
