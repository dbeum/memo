import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class annual extends StatefulWidget {
  @override
  _annualState createState() => _annualState();
}

class _annualState extends State<annual> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  String? leaveType;
  DateTime? startDate;
  DateTime? endDate;
  int? requestedDays;
  File? _documentFile;
  bool _isLoading = false;

  String? role;
  int leaveBalance = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }
      final userId = user.uid;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception("User document does not exist");
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      setState(() {
        role = userData['role'];
        leaveBalance = userData['leaveBalance'] ?? 0;
        print('Role: $role, Leave Balance: $leaveBalance'); // Debug statement
      });
    } catch (e) {
      print("Error fetching user data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while fetching user data.'),
        ),
      );
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      final user = FirebaseAuth.instance.currentUser;
      final userId = user!.uid;

      try {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final userData = userDoc.data() as Map<String, dynamic>;
        final currentBalance = userData['leaveBalance'];

        final startDateTimestamp = Timestamp.fromDate(startDate!);
        final endDateTimestamp = Timestamp.fromDate(endDate!);
        final requestedDays = endDate!.difference(startDate!).inDays + 1;

        String? documentUrl;
        if (_documentFile != null) {
          final storageRef = FirebaseStorage.instance.ref().child('leave_documents/$userId/${DateTime.now().toIso8601String()}');
          final uploadTask = storageRef.putFile(_documentFile!);
          final snapshot = await uploadTask.whenComplete(() => {});
          documentUrl = await snapshot.ref.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('leaveRequests').add({
          'userId': userId,
          'leaveType': leaveType,
          'startDate': startDateTimestamp,
          'endDate': endDateTimestamp,
          'reason': _reasonController.text,
          'documentUrl': documentUrl ?? '',
          'status': 'Pending',
          'requestedDays': requestedDays,
          'originalBalance': currentBalance,
        });

        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'leaveBalance': currentBalance - requestedDays,
        });

        Navigator.pop(context);
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _documentFile = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role == null) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    int maxDays;
    switch (role) {
      case 'Junior Staff':
        maxDays = 18;
        break;
      case 'Senior Staff':
        maxDays = 21;
        break;
      case 'Lecturer':
        maxDays = 30;
        break;
      default:
        maxDays = 0;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Annual Leave Request'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Text('Current Date: ${DateFormat.yMMMd().format(DateTime.now())}'),
                    SizedBox(height: 16),
                    Text('Role: $role'),
                    Text('Leave Balance: $leaveBalance days'),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Leave Type'),
                      items: ['Annual Leave', 'Sick Leave', 'Maternity Leave']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ))
                          .toList(),
                      onChanged: (value) => leaveType = value,
                      validator: (value) => value == null ? 'Please select a leave type' : null,
                    ),
                    SizedBox(height: 16),
                    ListTile(
                      title: Text(startDate == null ? 'Select Start Date' : 'Start Date: ${DateFormat.yMMMd().format(startDate!)}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            startDate = date;
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text(endDate == null ? 'Select End Date' : 'End Date: ${DateFormat.yMMMd().format(endDate!)}'),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            endDate = date;
                          });
                        }
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Reason'),
                      controller: _reasonController,
                      validator: (value) => value!.isEmpty ? 'Please provide a reason' : null,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickDocument,
                      child: Text('Attach Document (Optional)'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (startDate != null && endDate != null) {
                            requestedDays = endDate!.difference(startDate!).inDays + 1;
                            if (requestedDays! > leaveBalance) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('You cannot request more days than your remaining balance'),
                                ),
                              );
                            } else {
                              _submitLeaveRequest();
                            }
                          }
                        }
                      },
                      child: Text('Submit Leave Request'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
