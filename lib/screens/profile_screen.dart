import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _usernameController = TextEditingController();

  Future updateUserProfile(String newUsername) async {
    if (user != null) {
      await _firestore.collection('users').doc(user!.uid).update({
        'username': newUsername,
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _firestore.collection('users').doc(user!.uid).get().then((doc) {
        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _usernameController.text = data['username'] ?? '';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Your Profile', style: TextStyle(color: Color.fromARGB(
            255, 148, 98, 214))),
    centerTitle: true,
    backgroundColor: Colors.transparent,
    elevation: 0,
    ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SizedBox(height: 20), // Add space above the profile picture
          CircleAvatar(
            radius: 60, // Adjust the size of the profile picture
            backgroundColor: Colors.grey, // Placeholder color
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // TODO: Implement profile picture change
              },
            ),
          ),
          SizedBox(height: 40), // Add space below the profile picture
          ListTile(
            title: Text('Your interests'),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: () {
              // TODO: Implement navigation to interests selection
            },
          ),
          ListTile(
            title: Text('Your native language'),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: () {
              // TODO: Implement navigation to native language selection
            },
          ),
          ListTile(
            title: Text('Your preferred languages'),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: () {
              // TODO: Implement navigation to preferred languages selection
            },
          ),
          SizedBox(height: 20), // Add space above the save button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              child: Text('Save changes'),
              onPressed: () {
                // TODO: Implement save changes logic
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.deepPurple, // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}