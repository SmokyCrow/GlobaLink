import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globalink/services/chat/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String recieverUserEmail;
  final String recieverUserID;
  const ChatScreen({super.key, required this.recieverUserEmail, required this.recieverUserID});

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


          _buildMessageInput()
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



  Widget _buildMessageItem(DocumentSnapshot document){
    Map<String, dynamic> data = document.data()as Map<String, dynamic>;
    var alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid) ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        children: [
          Text(data['senderEmail']),
          Text(data['message']),
        ],
      ),
    );
  }

  Widget _buildMessageInput(){
    return Row(
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
    );
  }


}
