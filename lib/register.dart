import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'register.dart';


class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _registerState();
}

class _registerState extends State<register> {
 //String selectedValue = 'Undergraduate';
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
        //  Text('MEMBER TYPE',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
         //  Container(
       // height: 30,
        //width: 200,
       //     decoration: BoxDecoration(
         //     border: Border.all(color: Colors.black,width: 2),
      //        borderRadius: BorderRadius.all(Radius.circular(5))
       //     ),
      //    child:  DropdownButton<String>(
        //                    value: selectedValue,
      //                  onChanged: (String? newValue) {
        //                },
          //              items: <String>['Undergraduate', 'Academic Staff', 'Non Academic Staff', 'Guardian'].map((String value) {
            //              return DropdownMenuItem<String>(
              //              value: value,
                //            child: Text(value),
                  //        );
      //                      }).toList(),
        //                    style:TextStyle(
      //                  color: Colors.blue[900],fontWeight: FontWeight.bold
        //                ),
          //              underline: Container(),
            //             alignment: Alignment.center,
              //        ),
                //    ),
                 
        //   SizedBox(height: 20,),
      
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
        try{

          final UserCredential= await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      
           print(UserCredential);
        }
      on FirebaseAuthException  catch (e){
        if (e.code=='invalid-credential'){
          print('Invalid Credential');
        }  
        }
         }, 
         child: Text('LOGIN',style: TextStyle(color: Colors.white),),
         
          ),
          
       ),
       //SizedBox(height: 2,),
 
 
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
 height: 200,
      width: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
    child: Column(
      children: [
        SizedBox(height: 20,),
        Text('USERNAME/MATRIC NUMBER',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
     Container(
      height: 30,
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black,width: 2),
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: TextField(
        //controller: ,
        autocorrect: false,
        enableSuggestions: true,
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
        //controller: ,
        autocorrect: false,
        enableSuggestions: true,
        ),
     ),
 //    SizedBox(height: 20,),
   //     Text('MEMBER TYPE',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
 //    Container(
 //     height: 30,
//      width: 200,
//      decoration: BoxDecoration(
//        border: Border.all(color: Colors.black,width: 2),
//        borderRadius: BorderRadius.all(Radius.circular(5))
  //    ),
    //  child:  DropdownButton<String>(
      //                value: selectedValue,
        //              onChanged: (String? newValue) {
          //              setState(() {
            //              selectedValue = newValue!;
              //          });
                //      },
  //                    items: <String>['Undergraduate', 'Academic Staff', 'Non Academic Staff', 'Guardian'].map((String value) {
    //                    return DropdownMenuItem<String>(
      //                    value: value,
        //                  child: Text(value),
          //              );
            //          }).toList(),
              //        style:TextStyle(
                //      color: Colors.blue[900],fontWeight: FontWeight.bold
                  //    ),
                    //  underline: Container(),
   //                 ),
     //             ),
               
     SizedBox(height: 20,),

     Container(
      height: 25,
      width: 100,
      decoration: BoxDecoration(
      color: Colors.black,
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child: TextButton(
       onPressed: () {
         
       },
       child: Text('LOGIN',style: TextStyle(color: Colors.white),),
        ),
     )
      ],
    ),
      
      
    ),
  
    ],
  
  )
   
  )  
  );
}
}