import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RoomsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    // Query all chat rooms
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('chat_rooms').snapshots(), // Corrected collection name
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No chat rooms found'));
        }

        // Build the list of chat rooms
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var roomData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            String roomId = snapshot.data!.docs[index].id;

            // Here you could extract more room details if you have them in the document, such as 'lastMessage', 'roomName', etc.
            // For demonstration, we'll just show the room ID.
            return ListTile(
              title: Text('Room ID: $roomId'),
              onTap: () {
                // Here you'd navigate to the chat room, passing in the room ID to the chat screen
                // Navigator.of(context).push(...);
              },
            );
          },
        );
      },
    );
  }
}

