import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class LeaveRequestForm extends StatefulWidget {
  const LeaveRequestForm({Key? key}) : super(key: key);

  @override
  _LeaveRequestFormState createState() => _LeaveRequestFormState();
}

class _LeaveRequestFormState extends State<LeaveRequestForm> {
  late final TextEditingController _reasonController;
  String _selectedLeaveType = 'Annual Leave';
  PlatformFile? _pickedFile;

  @override
  void initState() {
    _reasonController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _pickedFile = result.files.first;
      });
    }
  }

  Future<String?> _uploadFile(String userId) async {
    if (_pickedFile != null) {
      final storageRef = FirebaseStorage.instance.ref().child('leave_requests/${userId}/${_pickedFile!.name}');
      final uploadTask = storageRef.putData(_pickedFile!.bytes!);

      final snapshot = await uploadTask.whenComplete(() => {});
      return await snapshot.ref.getDownloadURL();
    }
    return null;
  }

  Future<void> _submitLeaveRequest(String userId) async {
    final reason = _reasonController.text;
    final leaveType = _selectedLeaveType;
    final pdfUrl = await _uploadFile(userId);

    await FirebaseFirestore.instance.collection('leave_requests').add({
      'leaveType': leaveType,
      'reason': reason,
      'userId': userId,
      'pdfUrl': pdfUrl,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave request submitted successfully')));

    // Clear the form
    _reasonController.clear();
    setState(() {
      _selectedLeaveType = 'Annual Leave';
      _pickedFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Request')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Leave Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedLeaveType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLeaveType = newValue!;
                });
              },
              items: <String>['Annual Leave', 'Sick Leave', 'Maternity Leave', 'Casual Leave', 'Examination Leave']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            Text('Reason', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter the reason for leave',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickFile,
              child: Text(_pickedFile == null ? 'Pick File' : 'File Selected: ${_pickedFile!.name}'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await _submitLeaveRequest(user.uid);
                }
              },
              child: Text('Submit Leave Request'),
            ),
          ],
        ),
      ),
    );
  }
}
