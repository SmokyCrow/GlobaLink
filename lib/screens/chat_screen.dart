import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globalink/services/chat/chat_service.dart';
import 'package:globalink/services/translation/translation_service.dart';
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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TranslationService _translationService = TranslationService("952f35b2-563a-6d96-4e47-6cd7c1991ff0:fx"); // Initialize with your API key
  bool _isLoadingMessages = true;
  final Map<String, bool> _messageToggleStates = {};
  List<String> allStarterMessages = ["___", "___", "___", "___"];
  List<String> _translatedStarterMessages = [];

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
    _fetchAllStarterMessages();
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
              child: _buildMessageList(),
            ),
          ),
          _buildMessageInput(),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final messageStream = _chatService.getMessages(
        widget.recieverUserID, _firebaseAuth.currentUser!.uid);

    return StreamBuilder<QuerySnapshot>(
      stream: messageStream,
      builder: (context, snapshot) {
        if (_isLoadingMessages &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState == ConnectionState.active) {
          _isLoadingMessages = false;
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildStarterMessages();
        }

        var messageDocs = snapshot.data!.docs;

        return ListView.builder(
          controller: scrollController,
          reverse: true,
          itemCount: messageDocs.length,
          itemBuilder: (context, index) {
            return _buildMessageItem(messageDocs[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isSender = data['senderId'] == _firebaseAuth.currentUser!.uid;
    String messageId = document.id; // The document ID is used as the message ID

    // Determine if the original message should be shown, default to false for receiver
    bool showOriginal = _messageToggleStates[messageId] ?? isSender;


    // Determine which message to display
    String displayMessage;
    if(isSender && showOriginal){
      displayMessage = data['message'];
    } else if(isSender && !showOriginal){
      displayMessage = data['senderTranslated'];
    } else if(!isSender && !showOriginal){
      displayMessage = data['receiverTranslated'];
    } else if(!isSender && showOriginal){
      displayMessage = data['receiverPreferredTranslated'];
    } else{
      displayMessage = "";
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _messageToggleStates[messageId] = !(_messageToggleStates[messageId] ?? isSender);
        });
      },
      child: Align(
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
            top: 4.0,
            bottom: 4.0,
            left: isSender ? 50.0 : 15.0,
            right: isSender ? 15.0 : 50.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          decoration: BoxDecoration(
            color: isSender ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            displayMessage,
            style: const TextStyle(
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15.0, 5.0, 5.0, 5.0),
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              ),
              textInputAction: TextInputAction.send,
            ),
          ),
          IconButton(
            onPressed: sendMessage,
            icon: Icon(Icons.send, color: Colors.blue.shade900),
          ),
        ],
      ),
    );
  }

  Widget _buildStarterMessages() {
    List<String> starterMessages = _translatedStarterMessages;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Choose an initial message:"),
        const SizedBox(height: 10),
        Column(
          children: starterMessages.map((message) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _sendMessageOnSelect(message);
                  },
                  child: Text(message),
                ),
                SizedBox(height: 10),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  void _sendMessageOnSelect(String selectedMessage) async {
    // Send the selected message as a normal message
    await _chatService.sendMessage(widget.recieverUserID, selectedMessage);

    // Clear the message input field
    _messageController.clear();

    // Scroll to the bottom of the message list
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _fetchAllStarterMessages() async {
    try {
      setState(() {
        _isLoadingUserData = true;
      });

      final starterMessagesdoc = await _firestore.collection('centraldata').doc('starterMessages').get();
      final currentDoc = await _firestore.collection('users').doc(_firebaseAuth.currentUser!.uid).get();
      String currentNativeLanguage = currentDoc['native_language'];

      if (starterMessagesdoc.exists && starterMessagesdoc.data() != null) {
        allStarterMessages = List<String>.from(starterMessagesdoc.data()?['startedMessages'] ?? ["Hello!", "Hey!", "Hi", "Yo!"]);
        allStarterMessages.shuffle();
        allStarterMessages = allStarterMessages.sublist(0, 4);
        for (var i = 0; i < allStarterMessages.length; i++) {
          allStarterMessages[i] = await _translationService.translate(allStarterMessages[i], currentNativeLanguage);
        }

        setState(() {
          _translatedStarterMessages = List.from(allStarterMessages);
        });
      }

      setState(() {
        _isLoadingUserData = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUserData = false;
      });
    }
  }
}