import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:web_1/nav/roles/admin.dart';
//import 'package:web_1/editprofile.dart';
import 'package:web_1/home2.dart';
import 'package:web_1/nav/roles/amin1.dart';

import 'package:web_1/nav/roles/juniorf.dart';

import 'firebase_options.dart';
import 'register.dart';


class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
// String selectedValue = 'Undergraduate';
 //String selectedGender = 'Male';
 late final TextEditingController _email;
 late final TextEditingController _password;

@override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
   _email.dispose();
   _password.dispose();
    super.dispose();
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
   child: 
  Center(child: 
  Column(
    children: [
      SizedBox(height: 80,),
      Image.asset('images/logo.png',height: 200,),
       SizedBox(height: 50,),
Container(
 height: 210,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
    child: FutureBuilder(
      future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform
          ),

      builder: (context, snapshot) {
        //switch (snapshot.connectionState){
       //   case ConnectionState.done:
       return  Column(
        children: [
          SizedBox(height: 20,),
          Text('EMAIL',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
       Container(
        height: 30,
        width: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black,width: 2),
          borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: TextField(
          controller:_email ,
            keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: true,
          decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 15), // Adjust the vertical padding
      ),
          ),
       ),
       SizedBox(height: 20,),
          Text('PASSWORD',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
       Container(
        height: 30,
        width: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black,width: 2),
          borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: TextField(
          controller: _password,
          autocorrect: false,
          enableSuggestions: true,
          obscureText: true,
            decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 15), // Adjust the vertical padding
      ),
          ),
       ),
       SizedBox(height: 20,),
      
      
       Container(
        height: 25,
        width: 100,
        decoration: BoxDecoration(
        color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: TextButton(
         onPressed: () async{
      
          
           final email =_email.text;
           final password = _password.text;
       try {
    final UserCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
     if (UserCredential.user != null) {
      final user = UserCredential.user!;
      // Assuming you have a 'role' field in your Firestore document for users
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final _selectedRole = userData.data()?['role'];
       final _selectedGender = userData.data()?['gender'];
       
    if (_selectedRole == 'Admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => admin1())); // Navigate to admin screen
        }  else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => juniorF())); // Navigate to junior staff screen
        }
           print(UserCredential);
          
        }}
      on FirebaseAuthException  catch (e){
        if (e.code=='invalid-credential'){
          print('Invalid Credential');
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Credentials')));
        }  
        }
         }, 
         child: Text('LOGIN',style: TextStyle(color: Colors.white),),
         
          ),
          
       ),
       //SizedBox(height: 2,),
  TextButton(onPressed: () {
    Navigator.push(context, MaterialPageRoute(builder:(context) => home2() ));
  }, child:      Text('Register',style:TextStyle(fontSize: 10),))
        ],
      );
          //default:
          //return const Text('Loading...');
        }
    
      
    ),
)
  
    ],
  
  )
   
  )  
    
  );
}

Widget DeskTopNavBar() {
  return Container(
   
  
   child: 
  Center(child: 
  Column(
    children: [
      SizedBox(height: 80,),
      Image.asset('images/logo.png',height: 200,),
       SizedBox(height: 50,),
Container(
 height: 210,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
    child: FutureBuilder(
      future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform
          ),

      builder: (context, snapshot) {
        //switch (snapshot.connectionState){
       //   case ConnectionState.done:
       return  Column(
        children: [
          SizedBox(height: 20,),
          Text('EMAIL',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
       Container(
        height: 30,
        width: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black,width: 2),
          borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: TextField(
          controller:_email ,
            keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          enableSuggestions: true,
          decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 15), // Adjust the vertical padding
      ),
          ),
       ),
       SizedBox(height: 20,),
          Text('PASSWORD',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
       Container(
        height: 30,
        width: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black,width: 2),
          borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: TextField(
          controller: _password,
          autocorrect: false,
          enableSuggestions: true,
          obscureText: true,
            decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 15), // Adjust the vertical padding
      ),
          ),
       ),
      
                 
           SizedBox(height: 20,),
      
       Container(
        height: 25,
        width: 100,
        decoration: BoxDecoration(
        color: Colors.black,
          borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: TextButton(
         onPressed: () async{
      
          
           final email =_email.text;
           final password = _password.text;
 try {
    final UserCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    // Check the selected role and navigate accordingly
    if (UserCredential.user != null) {
      final user = UserCredential.user!;
     
      final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final _selectedRole = userData.data()?['role'];
  final _selectedGender = userData.data()?['gender'];
  
   
      
    if (_selectedRole == 'Admin') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => admin1())); // Navigate to admin screen
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => juniorF())); // Navigate to junior staff screen
        }
    }
    print(UserCredential);
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-credential') {
      print('Invalid Credential');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid Credentials')));
    }
  }
},
         child: Text('LOGIN',style: TextStyle(color: Colors.white),),
         
          ),
          
       ),
       //SizedBox(height: 2,),
  TextButton(onPressed: () {
    Navigator.push(context, MaterialPageRoute(builder:(context) => home2() ));
  }, child:      Text('Register',style:TextStyle(fontSize: 10),))
        ],
      );
          //default:
          //return const Text('Loading...');
        }
    
      
    ),
)
  
    ],
  
  )
   
  )    
  );
}
}