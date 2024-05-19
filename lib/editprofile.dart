import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? employeeId;
  File? _imageFile;
  Uint8List? _webImage;
  final picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      }
    } else {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _uploadProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          String? imageUrl;
          if (_imageFile != null) {
            final ref = FirebaseStorage.instance
                .ref()
                .child('user_images')
                .child(user.uid + '.jpg');
            await ref.putFile(_imageFile!);
            imageUrl = await ref.getDownloadURL();
          } else if (_webImage != null) {
            final ref = FirebaseStorage.instance
                .ref()
                .child('user_images')
                .child(user.uid + '.jpg');
            await ref.putData(_webImage!);
            imageUrl = await ref.getDownloadURL();
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({
            'name': name,
            'employeeId': employeeId,
            'imageUrl': imageUrl,
          });

          Navigator.pop(context, true);
        }
      } catch (e) {
        // Print the error to the console for debugging
        print("Error: $e");
        // Display an error message to the user
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_webImage != null)
                      Image.memory(
                        _webImage!,
                        height: 150,
                        width: 150,
                      )
                    else if (_imageFile != null)
                      Image.file(
                        _imageFile!,
                        height: 150,
                        width: 150,
                      ),
                    TextButton.icon(
                      icon: Icon(Icons.image),
                      label: Text('Choose Image'),
                      onPressed: _pickImage,
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        name = value;
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Employee ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your employee ID';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        employeeId = value;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _uploadProfile,
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
