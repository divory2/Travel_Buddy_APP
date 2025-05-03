import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy_app/mainMenu.dart';
import 'package:travel_buddy_app/profile.dart';

class Matching extends StatefulWidget {
  Matching({Key? key, required this.auth, required this.user}) : super(key: key);
  final FirebaseAuth auth;
  final UserCredential user;
  @override
  _MatchingState createState() => _MatchingState();
}

class _MatchingState extends State<Matching> {
  FirebaseFirestore database = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = widget.auth;

    return Scaffold(
      appBar: AppBar(
        title: Text("Matching Buddy"),
      ),
       bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MainMenu(user: widget.user)));
          }
           if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(user: widget.user)));
          }
        },
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: database.collection('Profile').doc(_auth.currentUser?.uid).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return Center(child: Text('User profile not found.'));
          }

          final userData = userSnapshot.data!.data();
          if (userData == null || !userData.containsKey('interests')) {
            return Center(child: Text('Interests not specified.'));
          }

          List<String> currentUserInterests = List<String>.from(userData['interests']);
          // Normalize current user's interests (trim spaces and lowercase)
          List<String> normalizedCurrentUserInterests = currentUserInterests
              .map((interest) => interest.trim().toLowerCase())
              .toList();

          return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: database.collection('Profile').get(), // <-- fixed here: use 'Profile'
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return Center(child: Text('No users found.'));
              }

              var filteredData = snapshot.data!.docs.where((doc) {
                if (doc.id == _auth.currentUser?.uid) {
                  return false; // Skip yourself
                }

                var data = doc.data();
                if (data.containsKey('interests')) {
                  List<String> userInterests = List<String>.from(data['interests']);
                  // Normalize other user's interests
                  List<String> normalizedUserInterests = userInterests
                      .map((interest) => interest.trim().toLowerCase())
                      .toList();

                  // Check if any interests match
                  return normalizedUserInterests.any(
                      (interest) => normalizedCurrentUserInterests.contains(interest));
                }
                return false;
              }).toList();

              if (filteredData.isEmpty) {
                return Center(child: Text("No users with matching interests."));
              }

              return ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final user = filteredData[index].data();
                  return ListTile(
                    title: Text(user['userName'] ?? 'No Name'), // <-- assuming your Profile has 'userName'
                    subtitle: Text(user['interests'] != null
                        ? (user['interests'] as List<dynamic>).join(', ')
                        : 'No Interests'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}