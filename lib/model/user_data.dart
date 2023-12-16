import 'package:cloud_firestore/cloud_firestore.dart';

class UserData {
  final String email;
  final String uid;

  UserData({required this.email, required this.uid});

  factory UserData.fromMap(Map<String, dynamic> data, String uid) {
    return UserData(
      email: data['email'] ?? '',
      uid: uid,
    );
  }
}
Future<UserData> fetchUserDetails(String userId) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();
    if (userDoc.exists) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      return UserData.fromMap(userData, userId);
    } else {
      throw Exception('User not found');
    }
  } catch (e) {
    throw Exception('Error fetching user details: $e');
  }
}