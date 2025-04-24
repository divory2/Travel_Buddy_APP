import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

class MainMenu extends StatefulWidget{
 
  MainMenu({Key?key, required this.user}):super(key:key);
  final UserCredential user;
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