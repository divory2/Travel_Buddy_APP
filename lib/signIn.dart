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

  // Function to navigate to Register Email screen
  void _register() {
    final FirebaseAuth auth = widget.auth;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterEmail(auth: auth)),
    );
  }

  // Function to handle the sign-in logic
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

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainMenu(user: userCredential),
        ),
      );
    } catch (e) {
      setState(() {
        _success = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Sign in failed: ${e.toString()}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(14),
                alignment: Alignment.topCenter,
                child: Text("Sign in Page"),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _signIn();
                    }
                  },
                  child: Text("Sign in"),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _register,
                  child: Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
