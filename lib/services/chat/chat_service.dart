import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../../model/message.dart';
import '../translation/translation_service.dart';

class ChatService extends ChangeNotifier{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timeStamp = Timestamp.now();

    // Translate the message here if the receiver needs it
    String translatedMessage = await _translationService.translate(message, "HU");

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      translatedMessage: translatedMessage, // Set the translated message
      timeStamp: timeStamp,
    );

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");


    await _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());


  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId  = ids.join("_");

    return _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: false).snapshots();
  }

  final TranslationService _translationService = TranslationService("952f35b2-563a-6d96-4e47-6cd7c1991ff0:fx"); // Initialize with your API key

  // Add a method to determine if translation is needed
  Future<String> getDisplayMessage(String senderId, String message) async {
    if (_firebaseAuth.currentUser!.uid == senderId) {
      // If the current user is the sender, return the original message
      return message;
    } else {
      // If the current user is the receiver, translate the message
      return _translationService.translate(message, "HU");
    }
  }
}