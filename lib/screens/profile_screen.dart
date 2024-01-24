import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:globalink/services/translation/language_map.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _usernameController = TextEditingController();
  List<String> allInterests = []; // List of all interests fetched from Firebase
  List<String> userInterests = []; // User's current interests
  Set<String> selectedInterests = {}; // Selected interests
  List<String> allLanguages = []; // List of all available languages
  String? selectedLanguage; // Selected native language
  String? selectedPreferredLanguage; // User's preferred language
  String profilePictureUrl = ''; // Profile pictures url
  File? selectedProfilePicture; // The selected profile picture
  late Future _profileDataFuture; // Future to load profile data only once

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData().then((_) {
      // Show the welcome dialog only if certain profile data is not filled
      if (_usernameController.text.isEmpty || userInterests.isEmpty) {
        showWelcomeDialog();
      }
    });
  }

  void showWelcomeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Welcome to GlobaLink!'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('Before diving in, please complete your profile details. This is crucial for full access to our app\'s features.'),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Navigation Made Easy: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Seamlessly switch between different sections using the bottom navigation bar.'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Connect and Chat: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Discover and connect with new people on the \'New Chat\' page. Just click on a user to start a conversation.'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Personalize Your Profile: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Customize your profile anytime, adding a personal touch to your online presence.'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Know Who You\'re Chatting With: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Click on their name in the chat room to view their profile.'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '• ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Message Clarity: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: 'Switch between original and translated messages with a simple click, ensuring clear communication.'),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('We\'re excited to have you here and can\'t wait for you to explore GlobaLink!'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
        ],
      ),
    );
  }




  Future<void> _fetchProfileData() async {
    if (user != null) {
      await _firestore.collection('users').doc(user!.uid).get().then((doc) {
        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _usernameController.text = data['username'] ?? '';
          setState(() {
            profilePictureUrl = data['profile_picture_url'] ?? '';
            selectedLanguage =
                data['native_language']; // Update selectedLanguage
            selectedPreferredLanguage = data['preferred_language']; // Update selectedPreferredLanguage
          });
        }
      });
      await fetchAllInterests();
      await fetchUserInterests();
      await fetchLanguages();
    }
  }

  Future<void> uploadProfilePicture() async {
    final picker = ImagePicker();
    final XFile? pickedFile =
    await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedProfilePicture =
            File(pickedFile.path); // Store the selected picture temporarily
      });
    }
  }

  Future updateUserProfile(String newUsername) async {
    if (user != null) {

      Map<String, dynamic> updatedData = {
        'username': newUsername,
        'interests': userInterests
      };

      try {
        if (selectedProfilePicture != null) {
          String userId = user!.uid;
          Reference storageRef =
          FirebaseStorage.instance.ref().child("profile_pictures/$userId");

          try {
            UploadTask uploadTask = storageRef.putFile(selectedProfilePicture!);
            await uploadTask;
            String downloadUrl = await storageRef.getDownloadURL();

            // Update the profile picture URL in the updated data
            updatedData['profile_picture_url'] = downloadUrl;
          } catch (e) {
            // Handle any errors here
          }
        }

        if (selectedLanguage != null) {
          updatedData['native_language'] =
              selectedLanguage; // Include the selected native language
        }

        if (selectedPreferredLanguage != null) {
          updatedData['preferred_language'] = selectedPreferredLanguage;
        }

        if (newUsername.isNotEmpty &&
            newUsername != "" &&
            userInterests.isNotEmpty &&
            (profilePictureUrl.isNotEmpty ||
                updatedData['profile_picture_url'] != null) &&
            selectedLanguage != null &&
            selectedPreferredLanguage != null) {
          updatedData['profileComplete'] = true;
        } else {
          updatedData['profileComplete'] = false;
        }
        await _firestore.collection('users').doc(user!.uid).update(updatedData);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully!'),
              duration: Duration(seconds: 1)),
        );
      } catch (e) {
        // If an error occurs, stop the loading indicator and show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile.')),
        );
      }
    }
  }

  Future<void> fetchAllInterests() async {
    final interestsDoc =
    await _firestore.collection('centraldata').doc('interests').get();
    if (interestsDoc.exists && interestsDoc.data() != null) {
      setState(() {
        allInterests =
        List<String>.from(interestsDoc.data()?['interests'] ?? []);
      });
    }
  }

  Future<void> fetchUserInterests() async {
    final userDoc = await _firestore.collection('users').doc(user?.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        userInterests = List<String>.from(userDoc.data()?['interests'] ?? []);
      });
    }
  }

  Future<void> fetchLanguages() async {
    final languagesDoc =
    await _firestore.collection('centraldata').doc('languages').get();
    if (languagesDoc.exists && languagesDoc.data() != null) {
      setState(() {
        allLanguages =
        List<String>.from(languagesDoc.data()?['languages'] ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 30)),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:

            default:
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // Data is fetched so display the profile information
                return buildProfileContent();
              }
          }
        },
      ),
    );
  }

  Widget buildProfileContent() {
    // The content of the profile screen that depends on the loaded data
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20), // Add space above the profile picture
        GestureDetector(
          onTap: uploadProfilePicture,
          child: CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue.shade900,
            backgroundImage: (selectedProfilePicture != null)
                ? FileImage(selectedProfilePicture!)
                : (profilePictureUrl.isNotEmpty)
                ? NetworkImage(profilePictureUrl) as ImageProvider<Object>
                : null,
            child: (profilePictureUrl.isEmpty && selectedProfilePicture == null)
                ? const ClipOval(child: Icon(Icons.add_a_photo, color: Colors.white))
                : null,
          ),
        ),
        const SizedBox(height: 40), // Add space below the profile picture
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          margin: const EdgeInsets.only(bottom: 15), // Space between input fields
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('Your Interests'),
              textColor: Colors.blue.shade900,
              iconColor: Colors.blue.shade900,
              children: [
                SizedBox(
                  height: 200, // Fixed height for scrollable area
                  child: SingleChildScrollView(
                    child: Column(
                      children: allInterests.map((interest) {
                        bool isSelected = userInterests.contains(interest);
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                userInterests.remove(interest);
                              } else {
                                userInterests.add(interest);
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade900
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(interest,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          margin: const EdgeInsets.only(bottom: 15), // Space between input fields
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('Your Native Language'),
              textColor: Colors.blue.shade900,
              iconColor: Colors.blue.shade900,
              children: [
                SizedBox(
                  height: 200, // Fixed height for scrollable area
                  child: SingleChildScrollView(
                    child: Column(
                      children: (allLanguages
                          .where((language) =>
                      language != selectedPreferredLanguage)
                          .toList())
                          .map((language) {
                        bool isSelected = language == selectedLanguage;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                selectedLanguage =
                                null; // Deselect the language
                              } else {
                                selectedLanguage =
                                    language; // Select the language
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade900
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(languageMap[language] ?? language,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          margin: const EdgeInsets.only(bottom: 15), // Space between input fields
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('Preferred Language'),
              textColor: Colors.blue.shade900,
              iconColor: Colors.blue.shade900,
              children: [
                SizedBox(
                  height: 200, // Fixed height for scrollable area
                  child: SingleChildScrollView(
                    child: Column(
                      children: (allLanguages
                          .where((language) => language != selectedLanguage)
                          .toList())
                          .map((language) {
                        bool isSelected = language == selectedPreferredLanguage;
                        return InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                // Nothing happens
                              } else {
                                selectedPreferredLanguage =
                                    language; // Select the language
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.shade900
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(languageMap[language] ?? language,
                                style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20), // Add space above the save button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              labelStyle: TextStyle(color: Colors.blue.shade900),
              border: InputBorder.none,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 20),
          child: ElevatedButton(
            onPressed: () async {
              await updateUserProfile(_usernameController.text);
              // Add logic to show a confirmation message
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade900, // Button background color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            child: const Text('Save changes',
                style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}