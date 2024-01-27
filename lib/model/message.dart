import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final String receiverTranslated; // New field
  final String senderTranslated;
  final String receiverPreferredTranslated;
  final Timestamp timeStamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    this.receiverTranslated = '', // Default to empty string
    this.receiverPreferredTranslated = '',
    this.senderTranslated = '',
    required this.timeStamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'receiverTranslated': receiverTranslated, // Include in map
      'senderTranslated' : senderTranslated,
      'receiverPreferredTranslated' : receiverPreferredTranslated,
      'timestamp': timeStamp,
    };
  }
}