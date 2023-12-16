import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import '../model/user_data.dart';
import 'chat_screen.dart'; // Update this import to your ChatScreen

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  _RoomsScreenState createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  Widget _buildAvatar(types.Room room) {
    var color = Colors.transparent;

    if (room.type == types.RoomType.direct) {
      try {
        final otherUser = room.users.firstWhere(
              (u) => u.id != _user!.uid,
        );
        color = getUserAvatarNameColor(otherUser);
      } catch (e) {
        // Do nothing if other user is not found.
      }
    }

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
          name.isEmpty ? '' : name[0].toUpperCase(),
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (_user == null) {
      return Center(child: Text('Not authenticated'));
    }

    return StreamBuilder<List<types.Room>>(
      stream: FirebaseChatCore.instance.rooms(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No rooms'));
        }

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final room = snapshot.data![index];

            return GestureDetector(
              onTap: () async {
                final otherUserId = room.users.firstWhere((u) => u.id != _user!.uid).id;

                try {
                  UserData otherUserDetails = await fetchUserDetails(otherUserId);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        recieverUserEmail: otherUserDetails.email,
                        recieverUserID: otherUserId,
                      ),
                    ),
                  );
                } catch (e) {
                  // Handle the error, perhaps show a snackbar or alert dialog
                  print('Error fetching user details: $e');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildAvatar(room),
                    Text(room.name ?? ''),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Add the getUserAvatarNameColor method if it's not already there
Color getUserAvatarNameColor(types.User user) {
  // Your implementation here...
  return Colors.blue; // Placeholder
}

