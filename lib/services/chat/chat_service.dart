import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../model/message.dart';
import '../translation/translation_service.dart';

class ChatService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String receiverId, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timeStamp = Timestamp.now();

    // Retrieve the receiver's native language
    DocumentSnapshot receiverSnapshot = await _fireStore.collection('users').doc(receiverId).get();
    String receiverLanguage = receiverSnapshot['native_language'];
    String receiverPreferredLanguage = receiverSnapshot['preferred_language'];


    DocumentSnapshot senderSnapshot = await _fireStore.collection('users').doc(currentUserId).get();
    String senderPreferredLanguage = senderSnapshot['preferred_language'];

    // Translate the message here if the receiver needs it

    String receiverTranslated = await _translationService.translate(message, receiverLanguage);
    String receiverPreferredTranslated = message;
    String senderTranslated = await _translationService.translate(message, receiverLanguage);
    if(senderPreferredLanguage != ""){
      senderTranslated = await _translationService.translate(message, senderPreferredLanguage);
    }
    if(receiverPreferredLanguage != ""){
      receiverPreferredTranslated = await _translationService.translate(message, receiverPreferredLanguage);
    }


    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      receiverTranslated: receiverTranslated, // Set the translated message
      senderTranslated: senderTranslated,
      receiverPreferredTranslated: receiverPreferredTranslated,
      timeStamp: timeStamp,
    );


    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    final myMap = <String, int>{};
    await _fireStore.collection('chat_rooms').doc(chatRoomId).set(myMap);

    await _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').add(newMessage.toMap());


  }

  Stream<QuerySnapshot> getMessages(String userId, String otherUserId){
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId  = ids.join("_");

    return _fireStore.collection('chat_rooms').doc(chatRoomId).collection('messages').orderBy('timestamp', descending: true).snapshots();
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

  // Method to check if a conversation exists between two users
  Future<bool> hasConversation(String user1Id, String user2Id) async {
    try {
      String chatRoomId1 = "${user1Id}_$user2Id";
      String chatRoomId2 = "${user2Id}_$user1Id";

      DocumentSnapshot chatRoomSnapshot1 = await _fireStore.collection('chat_rooms').doc(chatRoomId1).get();
      DocumentSnapshot chatRoomSnapshot2 = await _fireStore.collection('chat_rooms').doc(chatRoomId2).get();
      bool b1 = chatRoomSnapshot1.exists;
      bool b2 = chatRoomSnapshot2.exists;
      return b1 || b2;

    } catch (e) {
      print("Error checking conversation: $e");
      return false;
    }
  }

  Future<void> updatePreferredTranslations(String newPreferredLanguage, String userId) async {
    final QuerySnapshot messagesSnapshot = await _fireStore
        .collectionGroup('messages').get();

    for (var doc in messagesSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      bool isSender = data['senderId'] == userId;
      bool isReceiver = data['receiverId'] == userId;

      // Check if the user is the sender or receiver
      if (isSender) {
        // Logic when the sender is updating the preferred language
        if (newPreferredLanguage != "none") {
          String newSenderTranslation = await _translationService.translate(
              data['message'], newPreferredLanguage);
          await doc.reference.update({
            'senderTranslated': newSenderTranslation,
          });
        } else {
          // Revert to the receiver's translation if the preferred language is set to "none"
          await doc.reference.update({
            'senderTranslated': data['receiverTranslated'],
          });
        }
      } else if (isReceiver) {
        // Logic when the receiver is updating the preferred language
        if (newPreferredLanguage != "none") {
          String newReceiverPreferredTranslation = await _translationService.translate(
              data['message'], newPreferredLanguage);
          await doc.reference.update({
            'receiverPreferredTranslated': newReceiverPreferredTranslation,
          });
        } else {
          // Revert to the original receiver translation if the preferred language is set to "none"
          await doc.reference.update({
            'receiverPreferredTranslated': data['message'],
          });
        }
      }
    }
  }





}