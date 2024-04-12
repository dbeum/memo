import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class login extends StatefulWidget {
  const login({super.key});

  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
 String selectedValue = 'Undergraduate';
  

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
 height: 300,
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
        //controller: ,
        autocorrect: false,
        enableSuggestions: true,
          decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(vertical: 15), // Adjust the vertical padding
    ),
        ),
     ),
     SizedBox(height: 20,),
        Text('MEMBER TYPE',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
     Container(
      height: 30,
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black,width: 2),
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child:  DropdownButton<String>(
                      value: selectedValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue!;
                        });
                      },
                      items: <String>['Undergraduate', 'Academic Staff', 'Non Academic Staff', 'Guardian'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      style:TextStyle(
                      color: Colors.blue[900],fontWeight: FontWeight.bold
                      ),
                      underline: Container(),
                       alignment: Alignment.center,
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
 height: 300,
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
     SizedBox(height: 20,),
        Text('MEMBER TYPE',style: TextStyle(fontSize: 11,fontWeight: FontWeight.bold),),
     Container(
      height: 30,
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black,width: 2),
        borderRadius: BorderRadius.all(Radius.circular(5))
      ),
      child:  DropdownButton<String>(
                      value: selectedValue,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedValue = newValue!;
                        });
                      },
                      items: <String>['Undergraduate', 'Academic Staff', 'Non Academic Staff', 'Guardian'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      style:TextStyle(
                      color: Colors.blue[900],fontWeight: FontWeight.bold
                      ),
                      underline: Container(),
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