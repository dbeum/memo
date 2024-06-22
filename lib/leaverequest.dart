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
  DateTime? _startDate;
  DateTime? _endDate;
  PlatformFile? _pickedFile;
  String? _userGender;
  List<String> _leaveTypes = ['Annual Leave', 'Sick Leave', 'Casual Leave', 'Examination Leave'];
  Map<String, dynamic> _leaveBalances = {};

  @override
  void initState() {
    _reasonController = TextEditingController();
    super.initState();
    _fetchUserGender();
     _fetchLeaveBalances();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserGender() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      if (userData != null && userData.containsKey('gender')) {
        setState(() {
          _userGender = userData['gender'];
          if (_userGender == 'Female') {
            _leaveTypes.add('Maternity Leave');
          }
        });
      }
    }
  }

 
  Future<void> _fetchLeaveBalances() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();
      if (userData != null && userData.containsKey('leaveBalances')) {
        setState(() {
          _leaveBalances = Map<String, dynamic>.from(userData['leaveBalances']);
        });
      }
    }
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

  Future<void> _submitLeaveRequest() async {
    final reason = _reasonController.text;
    final leaveType = _selectedLeaveType;
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && _startDate != null && _endDate != null) {
      final attachmentUrl = await _uploadFile(user.uid);

      await FirebaseFirestore.instance.collection('leave_requests').add({
        'leaveType': leaveType,
        'reason': reason,
        'userId': user.uid,
        'status': 'pending',
        'pdfUrl': attachmentUrl,
        'startDate': _startDate,
        'endDate': _endDate,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Leave request submitted successfully')));

      // Clear the form
      _reasonController.clear();
      setState(() {
        _selectedLeaveType = 'Annual Leave';
        _pickedFile = null;
        _startDate = null;
        _endDate = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all fields')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Request')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Annual Leave Balance: ${_leaveBalances['Annual Leave'] ?? 'N/A'} days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Casual Leave Balance: ${_leaveBalances['Casual Leave'] ?? 'N/A'} days', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Leave Type', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: _selectedLeaveType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLeaveType = newValue!;
                });
              },
              items: _leaveTypes.map<DropdownMenuItem<String>>((String value) {
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
            Text('Start Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(Duration(days: 2)),
                  firstDate: DateTime.now().add(Duration(days: 2)),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() {
                    _startDate = selectedDate;
                    _endDate = null; // Reset end date if start date is changed
                  });
                }
              },
              child: Text(_startDate == null ? 'Select Start Date' : _startDate!.toLocal().toString().split(' ')[0]),
            ),
            SizedBox(height: 20),
            Text('End Date', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ElevatedButton(
              onPressed: _startDate == null ? null : () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _startDate!.add(Duration(days: 1)),
                  firstDate: _startDate!.add(Duration(days: 1)),
                  lastDate: DateTime(2100),
                );
                if (selectedDate != null) {
                  setState(() {
                    _endDate = selectedDate;
                  });
                }
              },
              child: Text(_endDate == null ? 'Select End Date' : _endDate!.toLocal().toString().split(' ')[0]),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitLeaveRequest,
              child: Text('Submit Leave Request'),
            ),
          ],
        ),
      ),
    );
  }
}
