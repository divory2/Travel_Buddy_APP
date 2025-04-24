import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget{
 
  MainMenu({Key?key, required this.auth}):super(key:key);
  final FirebaseAuth auth;
   @override
   _MainMenuState createState() => _MainMenuState();

}
class _MainMenuState extends State<MainMenu>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Travel Buddy APP"),
        actions: <Widget>[
          ElevatedButton(onPressed: (){

          }, child: Text("Sign out"))
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: (){

            }, child: Text("Map")),

          ],
        ),
      ),
    );
  }
}