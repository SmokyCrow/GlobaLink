import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chat_screen.dart';

class UsersScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Query all users except the current user
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No users found'));
        }

        // Build the list of users
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var userData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String userId = snapshot.data!.docs[index].id;

            // Skip the current user
            if (userId == _auth.currentUser!.uid) return Container();

            String userEmail = userData['email'];

            return ListTile(
              title: Text(userEmail),
              onTap: () {
                // Navigate to a screen to start chatting with this user
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(recieverUserID: userId),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
