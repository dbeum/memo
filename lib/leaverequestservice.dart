import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class LeaveRequests extends StatelessWidget {
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

              print('Leave Request: $leaveRequest');
              print('pdfUrl: $pdfUrl');

              return ListTile(
                title: Text(leaveType),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reason: $reason'),
                    Text('Employee ID: $userId'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('leave_requests').doc(leaveRequest.id).update({
                          'status': 'approved',
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('leave_requests').doc(leaveRequest.id).update({
                          'status': 'rejected',
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.file_download),
                      onPressed: () async {
                        if (pdfUrl != null && pdfUrl.isNotEmpty) {
                          try {
                            final uri = Uri.parse(pdfUrl);
                            print('Launching URL: $pdfUrl');
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              print('Could not launch URL');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not launch URL')),
                              );
                            }
                          } catch (e) {
                            print('Invalid PDF URL: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid PDF URL: $e')),
                            );
                          }
                        } else {
                          print('No PDF attached');
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
