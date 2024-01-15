import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/animations.dart';
import 'chat_screen.dart';

class RoomsScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RoomsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentUserId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30)),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('chat_rooms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 17, 71, 160),));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chat rooms found'));
          }

          // Filter the rooms where the current user is a participant
          final rooms = snapshot.data!.docs.where((DocumentSnapshot document) {
            String roomId = document.id;
            return roomId.contains(currentUserId);
          }).toList();

          if (rooms.isEmpty) {
            return const Center(child: Text('No chat rooms found for this user'));
          }

          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              String roomId = rooms[index].id;
              // Identify the ID of the other user in the room
              String otherUserId = roomId.replaceAll(currentUserId, '').replaceAll('_', '');

              // Create a FutureBuilder to get the username of the other user
              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(otherUserId).get(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(title: Text('Loading...'));
                  }

                  if (userSnapshot.hasError) {
                    return ListTile(title: Text('Error: ${userSnapshot.error}'));
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const ListTile(title: Text('User not found'));
                  }

                  var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  String username = userData['username'] ?? 'No Name';

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(userData['profile_picture_url']),
                    ),
                    title: Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.chat),
                    onTap: () {
                      Navigator.push(context, SlideRightRoute(page: ChatScreen(recieverUserID: otherUserId)));
                    },
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

