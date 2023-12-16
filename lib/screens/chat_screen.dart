import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globalink/model/chat_bubble.dart';
import 'package:globalink/services/chat/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String recieverUserEmail;
  final String recieverUserID;
  const ChatScreen({
    super.key,
    required this.recieverUserEmail,
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
      appBar: AppBar(title: Text(widget.recieverUserEmail),),
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