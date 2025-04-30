import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy_app/mainMenu.dart';
import 'package:travel_buddy_app/register_email.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key, required this.auth}) : super(key: key);
  final FirebaseAuth auth;

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _success = false;
  String _userEmail = '';

  void _register() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterEmail(auth: widget.auth)),
    );
  }

  void _signIn() async {
    try {
      final userCredential = await widget.auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      setState(() {
        _success = true;
        _userEmail = userCredential.user?.email ?? '';
      });

      // Safely navigate after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainMenu(user: userCredential)),
        );
      });
    } catch (e) {
      setState(() {
        _success = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Sign in failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign In")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child:  Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                 SizedBox(height: 30,
                child:  Text("Sign in Page", style: Theme.of(context).textTheme.titleLarge),),
                //Expanded(
                  //child: 
                 // Column(
                    //children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) => value!.isEmpty ? 'Please enter an email' : null,
                      ),
                      //  SizedBox(height: 10,
                     // child: 
                       TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
                      ),//),
                      // TextFormField(
                      //   controller: _passwordController,
                      //   decoration: const InputDecoration(labelText: 'Password'),
                      //   obscureText: true,
                      //   validator: (value) => value!.isEmpty ? 'Please enter a password' : null,
                      // ),
                     // const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signIn();
                          }
                        },
                        child: const Text("Sign In"),
                      ),
                      ElevatedButton(
                        onPressed: _register,
                        child: const Text("Register"),
                      ),
                   // ],
                 // ),
                //),
              ],
            ),
          ),
        
      ),
    );
  }
}
