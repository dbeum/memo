import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_1/home.dart';
import 'firebase_options.dart';

class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
  String _selectedRole = 'Junior Staff';
  String _selectedGender = 'Male';
  String _selectedStaffType = 'Teaching Staff-CONAS';
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
    initializeFirebase();
  }

  Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

 Future<Map<String, dynamic>> getInitialLeaveBalances(String role, String staffType) async {
  const teachingStaffTypes = [
    'Teaching Staff-CONAS',
    'Teaching Staff-CBSS',
    'Teaching Staff-CACOS',
  ];
  
  if (role == 'Senior Staff' && teachingStaffTypes.contains(staffType)) {
    return {
      'Annual Leave': 30,
      'Casual Leave': 7,
      'Sick Leave': double.infinity,
      'Maternity Leave': double.infinity,
      'Examination Leave': double.infinity,
    };
  }
    switch (role) {
      case 'Junior Staff':
        return {
          'Annual Leave': 18,
          'Casual Leave': 7,
          'Sick Leave': double.infinity,
          'Maternity Leave': double.infinity,
          'Examination Leave': double.infinity,
        };
      case 'Senior Staff':
        return {
          'Annual Leave': 21,
          'Casual Leave': 7,
          'Sick Leave': double.infinity,
          'Maternity Leave': double.infinity,
          'Examination Leave': double.infinity,
        };
      default: // Default to Junior Staff
        return {
          'Annual Leave': 18,
          'Casual Leave': 7,
          'Sick Leave': double.infinity,
          'Maternity Leave': double.infinity,
          'Examination Leave': double.infinity,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (BuildContext context) => MobileNavBar(),
      desktop: (BuildContext context) => DeskTopNavBar(),
    );
  }

  Widget MobileNavBar() {
    return Container(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 80),
            Image.asset('images/logo.png', height: 200),
            SizedBox(height: 20),
            Container(
              height: 370,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: FutureBuilder(
                future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'EMAIL',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            enableSuggestions: true,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'PASSWORD',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: TextField(
                            controller: _password,
                            autocorrect: false,
                            enableSuggestions: true,
                            obscureText: true,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'MEMBER TYPE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRole,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRole = newValue!;
                                });
                              },
                              items: ['Junior Staff', 'Senior Staff'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                          SizedBox(height: 20),
                        Text(
                          'STAFF TYPE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStaffType,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStaffType = newValue!;
                                });
                              },
                              items: ['Teaching Staff-CONAS','Teaching Staff-CBSS','Teaching Staff-CACOS','Non-Teaching Staff'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                       
                        SizedBox(height: 20),
                        Text(
                          'GENDER',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGender,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue!;
                                });
                              },
                              items: ['Male', 'Female', 'Not Applicable'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 9),
                        Container(
                          height: 25,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final email = _email.text;
                              final password = _password.text;
                              final role = _selectedRole;
                              final staffType = _selectedStaffType;
                              final gender = _selectedGender;
                              try {
                                final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );

                                final leaveBalances = await getInitialLeaveBalances(role,staffType);

                                await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                                  'email': email,
                                  'role': role,
                                  'staffType': staffType,
                                  'gender': gender,
                                  'leaveBalances': leaveBalances,
                                });

                                print('User registered: ${userCredential.user!.uid}');
                                
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => home(),
                                  ),
                                );
                              } catch (e) {
                                if (e is FirebaseAuthException) {
                                  if (e.code == 'weak-password') {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Weak Password')));
                                    print('Weak password');
                                  } else if (e.code == 'email-already-in-use') {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email already in use')));
                                    print('Email is already in use');
                                  } else if (e.code == 'invalid-email') {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Email')));
                                    print('Invalid email');
                                  } else {
                                    print(e);
                                  }
                                } else {
                                  print('Unexpected error: $e');
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed')));
                              }
                            },
                            child: Text(
                              'REGISTER',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget DeskTopNavBar() {
    return Container(
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 80),
            Image.asset('images/logo.png', height: 200),
            SizedBox(height: 20),
            Container(
              height: 370,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: FutureBuilder(
                future: Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          'EMAIL',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            enableSuggestions: true,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'PASSWORD',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: TextField(
                            controller: _password,
                            autocorrect: false,
                            enableSuggestions: true,
                            obscureText: true,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'MEMBER TYPE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedRole,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedRole = newValue!;
                                });
                              },
                              items: ['Junior Staff', 'Senior Staff'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                         
                        Text(
                          'STAFF TYPE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedStaffType,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedStaffType = newValue!;
                                });
                              },
                              items: ['Teaching Staff-CONAS','Teaching Staff-CBSS','Teaching Staff-CACOS', 'Non-Teaching Staff'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                         SizedBox(height: 20),
                        Text(
                          'GENDER',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          height: 30,
                          width: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedGender,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedGender = newValue!;
                                });
                              },
                              items: ['Male', 'Female', 'Not Applicable'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: 9),
                        Container(
                          height: 25,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: TextButton(
                            onPressed: () async {
                              final email = _email.text;
                              final password = _password.text;
                              final role = _selectedRole;
                              final staffType = _selectedStaffType;
                              final gender = _selectedGender;
                              try {
                                final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );

                                final leaveBalances = await getInitialLeaveBalances(role,staffType);

                                await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                                  'email': email,
                                  'role': role,
                                  'gender': gender,
                                  'staffType': staffType,
                                  'leaveBalances': leaveBalances,
                                });

                                print('User registered: ${userCredential.user!.uid}');
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => home(),
                                  ),
                                );
                              } catch (e) {
                                if (e is FirebaseAuthException) {
                                  if (e.code == 'weak-password') {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Weak Password')));
                                    print('Weak password');
                                  } else if (e.code == 'email-already-in-use') {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Email already in use')));
                                    print('Email is already in use');
                                  } else if (e.code == 'invalid-email') {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Email')));
                                    print('Invalid email');
                                  } else {
                                    print(e);
                                  }
                                } else {
                                  print('Unexpected error: $e');
                                }
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed')));
                              }
                            },
                            child: Text(
                              'REGISTER',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
