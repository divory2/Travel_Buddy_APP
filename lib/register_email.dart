import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  String _userEmail = '';
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Form(
      key: _formKey,
      child: Column(
        children: [
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
              }

            }, child: Text("Sign in")),
          )
          

        ],

      )
    
    );
  }

}