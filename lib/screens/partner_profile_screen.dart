import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerProfileScreen extends StatelessWidget {
  final String userId;

  PartnerProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error loading profile."));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(child: Text("No profile found."));
            }
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            List<String> userInterests = List<String>.from(userData['interests'] ?? []);
            String nativeLanguage = userData['native_language'] ?? 'N/A';
            String username = userData['username'] ?? 'No Name';
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // Profile picture
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(userData['profile_picture_url'] ?? 'images/default_prof_picture.png'),
                  ),
                  SizedBox(height: 8), // Spacing between picture and name
                  // Username
                  Text(username, style: Theme.of(context).textTheme.headline6),
                  SizedBox(height: 16), // Spacing between name and interests
                  // Interests Section
                  Text('Interests:', textAlign: TextAlign.center),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.center,
                    children: userInterests.map((interest) => Chip(
                      label: Text(interest),
                    )).toList(),
                  ),
                  SizedBox(height: 16), // Spacing between interests and language
                  // Language Section
                  Text('Language:', textAlign: TextAlign.center),
                  Chip(
                    label: Text(nativeLanguage),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}