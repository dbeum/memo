import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LeaveRequests extends StatelessWidget {
  Future<void> approveLeaveRequest(BuildContext context, String requestId, String userId, String leaveType, int duration) async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData != null) {
        print('User data: $userData');
        final leaveBalances = userData['leaveBalances'] as Map<String, dynamic>;
        print('Leave balances: $leaveBalances');

        final double currentLeaveBalance = leaveBalances[leaveType]?.toDouble() ?? 0;
        print('Current leave balance for $leaveType: $currentLeaveBalance');
        print('Requested duration: $duration');

        if (currentLeaveBalance == double.infinity || currentLeaveBalance >= duration) {
          if (currentLeaveBalance != double.infinity) {
            final newLeaveBalance = currentLeaveBalance - duration;
            leaveBalances[leaveType] = newLeaveBalance;

            await FirebaseFirestore.instance.collection('users').doc(userId).update({
              'leaveBalances': leaveBalances,
            });
          }

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

  Future<void> rejectLeaveRequest(BuildContext context, String requestId, String reason) async {
    await FirebaseFirestore.instance.collection('leave_requests').doc(requestId).update({
      'status': 'rejected',
      'rejectionReason': reason,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave rejected successfully')));
  }

  Future<String?> showRejectionReasonDialog(BuildContext context) async {
    TextEditingController _reasonController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rejection Reason'),
          content: TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              hintText: 'Enter reason for rejection',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_reasonController.text);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data();
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

              final duration = startDate != null && endDate != null ? endDate.difference(startDate).inDays + 1 : 0;

              return FutureBuilder<Map<String, dynamic>?>(
                future: getUserData(userId),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text(leaveType),
                      subtitle: Text('Loading user details...'),
                    );
                  }

                  if (userSnapshot.hasError || !userSnapshot.hasData || userSnapshot.data == null) {
                    return ListTile(
                      title: Text(leaveType),
                      subtitle: Text('Failed to load user details'),
                    );
                  }

                  final userData = userSnapshot.data!;
                  final employeeId = userData.containsKey('employeeId') ? userData['employeeId'] : 'Unknown';

                  return ListTile(
                    title: Text(leaveType),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reason: $reason'),
                        Text('Employee ID: $employeeId'),
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
                            final reason = await showRejectionReasonDialog(context);
                            if (reason != null && reason.isNotEmpty) {
                              await rejectLeaveRequest(context, leaveRequest.id, reason);
                            }
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
          );
        },
      ),
    );
  }
}
