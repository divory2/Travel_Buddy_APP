import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:travel_buddy_app/mainMenu.dart';
import 'package:travel_buddy_app/matching.dart';
import 'package:travel_buddy_app/profile.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key?key, required this.user}):super(key:key);
  final UserCredential user;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int _selectedIndex = 0;
  final _auth = FirebaseAuth.instance;
  late final types.User _user;
  final _uuid = Uuid();

  @override
  void initState() {
    super.initState();
    final firebaseUser = _auth.currentUser!;
    _user = types.User(
      id: firebaseUser.uid,
      firstName: firebaseUser.email?.split('@')[0],
    );
  }

  void _handleSendPressed(types.PartialText message) async {
    await FirebaseFirestore.instance.collection('Profile').doc(_auth.currentUser?.uid).set({
      'text': message.text,
      'MessageCreatedAt': DateTime.now().millisecondsSinceEpoch,
      'userId': _user.id,
      
    });
  }

  List<types.Message> _transformMessages(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;

      return types.TextMessage(
        id: doc.id,
        author: types.User(id: data['userName'] ?? 'unknown'),
        createdAt: data['MessageCreatedAt'],
        text: data['text'] ?? '',
        
      );
    }).toList()
      ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.card_membership), label: 'Matching Buddy'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (value){
            if(value == 0){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> MainMenu(user: widget.user)));
            }else if(value == 1){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile(user: widget.user,)));
            }else if(value == 2){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> Matching(auth: _auth,user: widget.user,)));
            }
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Profile')
            .orderBy('MessageCreatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final messages = _transformMessages(snapshot.data!);

          return Chat(
            messages: messages,
            onSendPressed: _handleSendPressed,
            user: _user,
          );
        },
      ),
    );
  }
}
