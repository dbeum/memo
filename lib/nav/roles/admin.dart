
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class admin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user['name']),
                subtitle: Text('Employee ID: ${user['employeeId']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('users').doc(user.id).update({
                          'status': 'approved',
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('users').doc(user.id).update({
                          'status': 'rejected',
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.file_download),
                      onPressed: () async {
                        String? pdfUrl = user['pdfUrl'];
                        if (pdfUrl != null && pdfUrl.isNotEmpty) {
                          if (await canLaunch(pdfUrl)) {
                            await launch(pdfUrl);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not launch URL')),
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
