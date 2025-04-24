import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy_app/mainMenu.dart';

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
  bool _sucess =false;
  bool _initialState = true;
  
  String _userEmail = '';

   void _signIn() async{
    try{
      final UserCredential = await widget.auth.signInWithEmailAndPassword(email: _emailController.text, password: _passwordController.text);
      setState(() {
        _sucess =true;
        _userEmail = UserCredential.user?.email ?? '';
        _initialState = false;

        
      });
      final FirebaseAuth auth = widget.auth;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MainMenu(auth: auth)));
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
                  _signIn;
              }

            }, child: Text("Sign in")),
          )
          

        ],

      )
    
    );
  }

}