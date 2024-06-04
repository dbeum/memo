
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InitialDataForm extends StatefulWidget {
  @override
  _InitialDataFormState createState() => _InitialDataFormState();
}

class _InitialDataFormState extends State<InitialDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _employeeIdController = TextEditingController();
  String? _imageUrl;
  PlatformFile? _pdfFile;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _pdfFile != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String pdfUrl = await _uploadPDF(user.uid);

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'employeeId': _employeeIdController.text,
          'imageUrl': _imageUrl,
          'pdfUrl': pdfUrl,
          'status': 'pending',
        }, SetOptions(merge: true));
      }
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a PDF file')),
      );
    }
  }

  Future<String> _uploadPDF(String userId) async {
    final storageRef = FirebaseStorage.instance.ref().child('user_docs/$userId/${_pdfFile!.name}');
    final uploadTask = storageRef.putData(_pdfFile!.bytes!);
    final snapshot = await uploadTask;
    final pdfUrl = await snapshot.ref.getDownloadURL();
    return pdfUrl;
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _pdfFile = result.files.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Provide Your Information'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _employeeIdController,
                decoration: InputDecoration(labelText: 'Employee ID'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your employee ID';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: _pickPDF,
                child: Text('Select PDF'),
              ),
              SizedBox(height: 5,),
              _pdfFile != null ? Text('Selected PDF: ${_pdfFile!.name}') : SizedBox(),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
