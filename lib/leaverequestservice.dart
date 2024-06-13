import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LeaveRequests extends StatelessWidget {
  Future<void> approveLeaveRequest(BuildContext context, String requestId, String userId, String leaveType, int duration) async {
    try {
      // Get the user document
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData != null) {
        // Add detailed logging for the user data
        print('User data: $userData');

        // Get the current leave balance
        final leaveBalances = userData['leaveBalances'] as Map<String, dynamic>;
        print('Leave balances: $leaveBalances');

        final double currentLeaveBalance = leaveBalances[leaveType]?.toDouble() ?? 0;
        print('Current leave balance for $leaveType: $currentLeaveBalance');
        print('Requested duration: $duration');

        // Check if the user has sufficient leave balance
        if (currentLeaveBalance == double.infinity || currentLeaveBalance >= duration) {
          // Deduct the leave balance
          if (currentLeaveBalance != double.infinity) {
            final newLeaveBalance = currentLeaveBalance - duration;
            leaveBalances[leaveType] = newLeaveBalance;

            // Update the user's leave balance
            await FirebaseFirestore.instance.collection('users').doc(userId).update({
              'leaveBalances': leaveBalances,
            });
          }

          // Update the leave request status
          await FirebaseFirestore.instance.collection('leave_requests').doc(requestId).update({
            'status': 'approved',
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave approved successfully')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Insufficient leave balance')));
        }
      } else {
        print('User data is null');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User data not found')));
      }
    } catch (e) {
      print('Error approving leave request: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error approving leave request: $e')));
    }
  }

  Future<void> rejectLeaveRequest(BuildContext context, String requestId) async {
    // Update the leave request status
    await FirebaseFirestore.instance.collection('leave_requests').doc(requestId).update({
      'status': 'rejected',
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave rejected successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel - Leave Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('leave_requests').where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final leaveRequests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: leaveRequests.length,
            itemBuilder: (context, index) {
              final leaveRequest = leaveRequests[index];
              final data = leaveRequest.data() as Map<String, dynamic>?;

              final leaveType = data != null && data.containsKey('leaveType') ? data['leaveType'] : 'Unknown';
              final reason = data != null && data.containsKey('reason') ? data['reason'] : 'No reason provided';
              final userId = data != null && data.containsKey('userId') ? data['userId'] : 'Unknown';
              final pdfUrl = data != null && data.containsKey('pdfUrl') ? data['pdfUrl'] : null;
              final startDate = data != null && data.containsKey('startDate') ? data['startDate'].toDate() : null;
              final endDate = data != null && data.containsKey('endDate') ? data['endDate'].toDate() : null;

              // Calculate the leave duration
              final duration = startDate != null && endDate != null ? endDate.difference(startDate).inDays + 1 : 0;

              return ListTile(
                title: Text(leaveType),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reason: $reason'),
                    Text('Employee ID: $userId'),
                    if (startDate != null && endDate != null)
                      Text('Duration: ${startDate.toLocal().toString().split(' ')[0]} to ${endDate.toLocal().toString().split(' ')[0]}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () async {
                        await approveLeaveRequest(context, leaveRequest.id, userId, leaveType, duration);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () async {
                        await rejectLeaveRequest(context, leaveRequest.id);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.file_download),
                      onPressed: () async {
                        if (pdfUrl != null && pdfUrl.isNotEmpty) {
                          try {
                            final uri = Uri.parse(pdfUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not launch URL')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid PDF URL: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No PDF attached')),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
