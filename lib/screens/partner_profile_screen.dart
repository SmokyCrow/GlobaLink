import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartnerProfileScreen extends StatelessWidget {
  final String userId;

  const PartnerProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading profile."));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text("No profile found."));
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
                  const SizedBox(height: 8), // Spacing between picture and name
                  // Username
                  Text(username, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16), // Spacing between name and interests
                  // Interests Section
                  const Text('Interests:', textAlign: TextAlign.center),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.center,
                    children: userInterests.map((interest) => Chip(
                      label: Text(interest),
                    )).toList(),
                  ),
                  const SizedBox(height: 16), // Spacing between interests and language
                  // Language Section
                  const Text('Language:', textAlign: TextAlign.center),
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