import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globalink/services/chat/chat_service.dart';
import 'chat_screen.dart';

class UsersScreen extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  UsersScreen({super.key});

  String _getListAsString(dynamic value) {
    if (value is List<dynamic>) {
      return value.join(', ');
    } else if (value is String) {
      return value;
    } else {
      return "";
    }
  }


  Widget _buildUserCard(String username, String interests, String nativeLanguage, String preferredLanguage) {
    List<dynamic> listInterests = interests.split(", ");
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Centered username without label
            Center(
              child: Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 8),
            // Vignettes pour les centres d'intérêts
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Interest: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 4,
                  runSpacing: 4,
                  children: listInterests.map((interest) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 17, 71, 160),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        interest,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Reste du contenu
            Text(
              'Language Preference: ${preferredLanguage.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Language Native: ${nativeLanguage.toUpperCase()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildUserGrid(QuerySnapshot snapshot, BuildContext context) {
    String currentUserNativeLanguage = '';
    List<String> currentUserInterests = [];
    String currentId = '';

    return FutureBuilder<List<Widget>>(
      future: Future.wait(
        snapshot.docs.map((doc) async {
          var userData = doc.data() as Map<String, dynamic>;
          String userId = doc.id;

          // Skip the current user
          if (userId == _auth.currentUser!.uid) {
            currentUserNativeLanguage = _getListAsString(userData['native_language']);
            currentUserInterests = List<String>.from(userData['interests']);
            currentId = _getListAsString(userData['uid']);
            return Container();
          }

          String id = _getListAsString(userData['uid']);
          String username = _getListAsString(userData['username']);
          String interests = _getListAsString(userData['interests']);
          String nativeLanguage = _getListAsString(userData['native_language']);
          String preferredLanguage = _getListAsString(userData['preferred_language']);


          bool hasConversation = await _chatService.hasConversation(currentId, id);


          if (nativeLanguage != currentUserNativeLanguage && !hasConversation) {
            await Future.delayed(const Duration(milliseconds: 10));

            bool hasCommonInterest = currentUserInterests.any((interest) => interests.contains(interest));


            if (hasCommonInterest) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        recieverUserID: userId,
                      ),
                    ),
                  );
                },
                child: _buildUserCard(username, interests, nativeLanguage, preferredLanguage),
              );
            }
          }

          return Container();
        }),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return Column(
          children: snapshot.data ?? [], // Utilisez snapshot.data qui contient la liste des widgets
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('New Chat', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30)),
            backgroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildUserGrid(snapshot.data!, context),
            ),
          ),
        );
      },
    );
  }
}
