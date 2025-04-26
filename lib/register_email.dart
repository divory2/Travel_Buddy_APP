import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy_app/mainMenu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterEmail extends StatefulWidget{
  RegisterEmail({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;

  @override
 _RegisterEmailState createState() => _RegisterEmailState();

}
class _RegisterEmailState extends State<RegisterEmail>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
   final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
 final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _userNameController.dispose();
    super.dispose();
  }
  FirebaseFirestore _dataBase = FirebaseFirestore.instance; //db instance 
  bool _sucess =false;
  bool _initialState = true;
  
  String _userEmail = '';

   void _signIn() async{
    try{

      print("*******before register");

      final UserCredential = await widget.auth.createUserWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
      
      print("****after register");
    
      setState(() {
        _sucess =true;
        _userEmail = UserCredential.user?.email ?? '';
        _initialState = false;

        
      });
      print("**********before insert into db");
         _dataBase.collection('Profile').doc(UserCredential.user?.uid).set({
        'email': _userEmail,
        'userName': _userNameController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'CreatedAt': Timestamp.now(),
        
        
      }).onError((e, _) => print("Error writing document: $e"));
      print("**********After insert into db");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MainMenu(user: UserCredential)));
      
      
    }
    catch(e){
      setState(() {
        
        _sucess =false;
        _initialState = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("sign in failed}  ${e.toString()}"),));

    }



  }
 @override
Widget build(BuildContext context) {
  return Scaffold( 
    appBar: AppBar(
      title: Text("Register Page"),
    ),
    body: SingleChildScrollView(
      child: Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'First Name'),
              validator: (value) {
                if(value?.isEmpty?? true){
                  return 'Please enter a First Name';
                }
                return null;
              },
          ),
           TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name'),
              validator: (value) {
                if(value?.isEmpty?? true){
                  return 'Please enter a Last Name';
                }
                return null;
              },
          ),
          TextFormField(
              controller: _userNameController,
              decoration: InputDecoration(labelText: 'UserName'),
              validator: (value) {
                if(value?.isEmpty?? true){
                  return 'Please enter a UserName';
                }
                return null;
              },
          ),
          TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              validator: (value) {
                if(value?.isEmpty?? true){
                  return 'Please enter a email';
                }
                return null;
              },
          ),
          TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              validator: (value) {
                if(value?.isEmpty?? true){
                  return 'Please enter a password';
                }
                return null;
              },

          ),
          Container( 
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            alignment: Alignment.center,
            child: ElevatedButton(onPressed: (){
              if(_formKey.currentState!.validate()){
                  // add method to handle sign in 
                  _signIn();
              }

            }, child: Text("Sign in")),
          ),
         

          

        ],

      )
    
    )
  )
    );
}


}