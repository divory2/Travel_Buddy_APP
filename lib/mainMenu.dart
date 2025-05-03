import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travel_buddy_app/chat_screen.dart';
import 'package:travel_buddy_app/itenerary_planner.dart';
import 'package:travel_buddy_app/map.dart';
import 'package:travel_buddy_app/matching.dart';
import 'package:travel_buddy_app/profile.dart';
import 'package:travel_buddy_app/signIn.dart';

class MainMenu extends StatefulWidget{
 
  MainMenu({Key?key, required this.user}):super(key:key);
  final UserCredential user;
  
   @override
   _MainMenuState createState() => _MainMenuState();

}
class _MainMenuState extends State<MainMenu>{

 final FirebaseFirestore _dataBase = FirebaseFirestore.instance;
   var data ={};

@override
  void initState(){
    FetchData();
    super.initState();
  }

  Future<void> FetchData() async{

    final docRef = _dataBase.collection("Profile").doc(widget.user.user?.uid);
    docRef.get().then(
      (DocumentSnapshot doc){
        data = doc.data() as Map<String,dynamic>;
        print("*********data user name: ***** ${data['userName']}");
      }
    );

  }
  @override
Widget build(BuildContext context) {
  final userDocStream = _dataBase
      .collection("Profile")
      .doc(widget.user.user?.uid)
      .snapshots(); // Real-time stream

  return StreamBuilder<DocumentSnapshot>(
    stream: userDocStream,
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

      return Scaffold(
        appBar: AppBar(
          leading: Text("Profile: ${data['userName'] ?? 'Loading...'}"),
          title: Text("Travel Buddy APP"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) =>
                          SignIn(auth: FirebaseAuth.instance)),
                  (route) => false,
                );
              },
              child: Text("Sign out"),
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Maps(user: widget.user)));
                  },
                  child: Text("Map")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Profile(user: widget.user)));
                  },
                  child: Text("Profile")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChatScreen(user: widget.user)));
                  },
                  child: Text("Chat")),
              ElevatedButton(
                  onPressed: () {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Matching(auth: auth, user: widget.user)));
                  },
                  child: Text("Buddy Matching")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Planner(user: widget.user)));
                  },
                  child: Text("Planner")),
            ],
          ),
        ),
      );
    },
  );
}

}