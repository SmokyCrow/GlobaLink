import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globalink/model/chat_bubble.dart';
import 'package:globalink/services/chat/chat_service.dart';
import 'partner_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String recieverUserID;
  const ChatScreen({
    super.key,
    required this.recieverUserID
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  void sendMessage() async{
    if(_messageController.text.isNotEmpty){
      await _chatService.sendMessage(widget.recieverUserID, _messageController.text);
    }
    _messageController.clear();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use a FutureBuilder to fetch and display the username
        title: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(widget.recieverUserID).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading...");
            }
            if (snapshot.hasError) {
              return const Text("Error");
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text("No user found");
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            String username = userData['username'] ?? 'No Name';
            String profilePictureUrl = userData['profile_picture_url'] ?? '';
            return GestureDetector(
              onTap: () {
                // Navigate to the partner's profile screen when the profile picture is tapped
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PartnerProfileScreen(userId: widget.recieverUserID),
                  ),
                );
              },
              child: Row(
                children: [
                  profilePictureUrl != ''
                      ? CircleAvatar(
                    backgroundImage: NetworkImage(profilePictureUrl),
                  )
                      : const CircleAvatar(
                    // Use a default image if profilePictureUrl is ''
                    backgroundImage: AssetImage('images/default_prof_picture.png'),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ); // Display the retrieved username
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),


          _buildMessageInput(),

          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildMessageList(){
    return StreamBuilder(
        stream: _chatService.getMessages(widget.recieverUserID, _firebaseAuth.currentUser!.uid),
        builder: (context, snapshot){
          if(snapshot.hasError){
            return Text('Error${snapshot.error}');
          }

          if(snapshot.connectionState == ConnectionState.waiting){
            return const Text("Loading...");
          }

          return ListView(
            children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
          );
        }
    );
  }



  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isSender = data['senderId'] == _firebaseAuth.currentUser!.uid;

    // Choose between original and translated message based on the sender
    String displayMessage = isSender ? data['message'] : (data['translatedMessage'] ?? data['message']);

    var alignment = isSender ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(data['senderEmail']),
            const SizedBox(height: 5),
            ChatBubble(message: displayMessage),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        children: [
          Expanded(
              child: TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  labelText: 'Enter message',
                  border: OutlineInputBorder(),
                ),
                obscureText: false,
              ),
          ),
          IconButton(onPressed: sendMessage, icon: const Icon(Icons.arrow_forward_ios)),
        ],
      ),
    );
  }
}