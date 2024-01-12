import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globalink/services/chat/chat_service.dart';
import '../model/animations.dart';
import 'partner_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String recieverUserID;
  const ChatScreen({super.key, required this.recieverUserID});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool _isLoadingMessages = true;

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.recieverUserID, _messageController.text);
    }
    _messageController.clear();
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _username = '';
  String _profilePictureUrl = '';
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _isLoadingMessages = true;
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      setState(() {
        _isLoadingUserData = true;
      });
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.recieverUserID)
          .get();
      var userData = userSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _username = userData['username'] ?? 'No Name';
        _profilePictureUrl = userData['profile_picture_url'] ?? '';
        _isLoadingUserData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _isLoadingUserData
            ? const Text("Loading...")
            : GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      SlideRightRoute(
                          page: PartnerProfileScreen(
                              userId: widget.recieverUserID)));
                },
                child: Row(
                  children: [
                    _profilePictureUrl != ''
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(_profilePictureUrl),
                          )
                        : const CircleAvatar(
                            // Use a default image if profilePictureUrl is ''
                            backgroundImage:
                                AssetImage('images/default_prof_picture.png'),
                          ),
                    const SizedBox(width: 10),
                    Text(
                      _username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
      ),
      body: Column(
        children: [
          Expanded(
            child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: _buildMessageList()),
          ),
          _buildMessageInput(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    // Use a stable stream reference
    final messageStream = _chatService.getMessages(
        widget.recieverUserID, _firebaseAuth.currentUser!.uid);

    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, snapshot) {
        // Check if we are still waiting for the first snapshot
        if (_isLoadingMessages &&
            snapshot.connectionState == ConnectionState.waiting) {
          // If so, show the loading indicator
          return const Center(child: CircularProgressIndicator());
        }

        // Once the data is loaded for the first time, set the loading state to false
        if (snapshot.connectionState == ConnectionState.active) {
          _isLoadingMessages = false;
        }

        // Handle errors
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        // Handle no data
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages yet."));
        }

        // Get the message documents
        var messageDocs = snapshot.data!.docs;

        // Now we return the ListView without showing the loading indicator
        return ListView.builder(
          controller: scrollController,
          reverse: true,
          itemCount: messageDocs.length,
          itemBuilder: (context, index) {
            // Build the message item with the document snapshot
            return _buildMessageItem(messageDocs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    // Extract the message data from the document snapshot.
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isSender = data['senderId'] == _firebaseAuth.currentUser!.uid;

    // Choose between the original and translated message.
    String displayMessage = isSender
        ? data['message']
        : (data['translatedMessage'] ?? data['message']);

    // Style the chat bubble based on the sender.
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4.0,
          bottom: 4.0,
          left: isSender ? 50.0 : 15.0, // Indent the sender's messages more.
          right: isSender ? 15.0 : 50.0, // Indent the receiver's messages more.
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue[100] : Colors.grey[200],
          // Conditional color based on the sender.
          borderRadius:
              BorderRadius.circular(20), // Rounded corners for the chat bubble.
        ),
        child: Text(
          displayMessage,
          style: const TextStyle(
              fontSize: 16.0), // Standard text size for messages.
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    // Style the message input field to be more in line with the provided example.
    return Container(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 5.0, 5.0),
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200], // Background color for the input area.
        borderRadius:
            BorderRadius.circular(30), // Rounded corners for the input field.
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message', // Placeholder text.
                border: InputBorder.none, // No border.
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0), // Padding inside the input field.
              ),
              textInputAction:
                  TextInputAction.send, // Keyboard action for sending.
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.send,
                color:
                    Theme.of(context).colorScheme.primary), // Send icon button.
          ),
        ],
      ),
    );
  }
}
