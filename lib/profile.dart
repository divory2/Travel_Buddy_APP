import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_buddy_app/mainMenu.dart';

class Profile extends StatefulWidget {
  Profile({Key? key, required this.user}) : super(key: key);
  final UserCredential user;

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final List<String> availableInterests = [
    "Hiking",
    "Cooking",
    "Gaming",
    "Reading",
    "Traveling",
    "Photography",
    "Music",
    "Sports"
  ];

  List<String> selectedInterests = [];

  FirebaseFirestore database = FirebaseFirestore.instance;

  Future<void> insertBio() async {
    print("Inserting bio into DB ******");
    try {
      await database.collection("Profile").doc(widget.user.user?.uid).update({
        'bio': _profileController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Bio updated successfully")),
      );
    } catch (e) {
      print("Error writing document: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update bio")),
      );
    }
  }

  void _showInterestSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Interests'),
          content: SingleChildScrollView(
            child: ListBody(
              children: availableInterests.map((interest) {
                return CheckboxListTile(
                  title: Text(interest),
                  value: selectedInterests.contains(interest),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedInterests.add(interest);
                      } else {
                        selectedInterests.remove(interest);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _saveSelectedInterests();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveSelectedInterests() async {
    try {
      print("Saving selected interests: $selectedInterests");
      await database.collection("Profile").doc(widget.user.user?.uid).update({
        'interests': selectedInterests,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Interests updated successfully")),
      );
    } catch (e) {
      print("Error updating interests: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update interests")),
      );
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController _newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Change Password"),
        content: TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(labelText: "New Password"),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Update"),
            onPressed: () async {
              try {
                await widget.user.user?.updatePassword(_newPasswordController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password updated successfully")));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update password")));
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showChangeUserNameDialog(BuildContext context) async {
    final TextEditingController _newUserNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Change UserName"),
        content: TextField(
          controller: _newUserNameController,
          decoration: InputDecoration(labelText: "Change UserName"),
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Update"),
            onPressed: () async {
              try {
                await database.collection("Profile").doc(widget.user.user?.uid).update({
                  'userName': _newUserNameController.text
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("UserName was updated")));
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update userName")));
              }
            },
          ),
        ],
      ),
    );
  }

  TextEditingController _profileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Profile Settings"),
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
        },
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              SizedBox(
                width: 250,
                child: TextField(
                  controller: _profileController,
                  decoration: InputDecoration(border: const OutlineInputBorder(), label: const Text("Enter your bio")),
                  maxLines: 3,
                ),
              ),
              ElevatedButton(
                onPressed: insertBio,
                child: Text("Save Bio"),
              ),
              ElevatedButton(
                onPressed: () {
                  _showChangePasswordDialog(context);
                },
                child: Text("Change Password"),
              ),
              ElevatedButton(
                onPressed: () {
                  _showChangeUserNameDialog(context);
                },
                child: Text("Change UserName"),
              ),
              ElevatedButton(
                onPressed: _showInterestSelectionDialog,
                child: Text("Select Interests"),
              ),
            ],
          );
        },
      ),
    );
  }
}
