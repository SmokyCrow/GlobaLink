import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  Set<String> selectedInterests = Set(); // Selected interests
  List<String> allLanguages = []; // List of all available languages
  String? selectedLanguage; // Selected native language
  String? selectedPreferredLanguage; // User's preferred language
  String profilePictureUrl = ''; // Profile pictures url
  File? selectedProfilePicture; // The selected profile picture

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _firestore.collection('users').doc(user!.uid).get().then((doc) {
        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _usernameController.text = data['username'] ?? '';
          setState(() {
            profilePictureUrl = data['profile_picture_url'] ?? '';
            selectedLanguage =
                data['native_language'] ?? null; // Update selectedLanguage
            selectedPreferredLanguage = data['preferred_language'] ?? null; // Update selectedPreferredLanguage
          });
        }
      });
      fetchAllInterests();
      fetchUserInterests();
      fetchLanguages();
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
          print("Error uploading profile picture: $e");
        }
      }

      if (selectedLanguage != null) {
        updatedData['native_language'] =
            selectedLanguage; // Include the selected native language
      }

      if (selectedPreferredLanguage != null) {
        updatedData['preferred_language'] = selectedPreferredLanguage;
      }

      if(
          newUsername.isNotEmpty &&
          newUsername != "" &&
          userInterests.isNotEmpty &&
          profilePictureUrl.isNotEmpty &&
          selectedLanguage != null &&
          selectedPreferredLanguage != null
      ){
        print(newUsername);
        print(userInterests);
        print(profilePictureUrl);
        print(selectedLanguage);
        print(selectedPreferredLanguage);
        updatedData['profileComplete'] = true;
      }
      else {
        print(newUsername);
        print(userInterests);
        print(profilePictureUrl);
        print(selectedLanguage);
        print(selectedPreferredLanguage);
        updatedData['profileComplete'] = false;
      }

      await _firestore.collection('users').doc(user!.uid).update(updatedData);
    }
  }

  void fetchAllInterests() async {
    final interestsDoc =
    await _firestore.collection('centraldata').doc('interests').get();
    if (interestsDoc.exists && interestsDoc.data() != null) {
      setState(() {
        allInterests =
        List<String>.from(interestsDoc.data()?['interests'] ?? []);
        print("Interests: $allInterests"); // Debugging print statement
      });
    }
  }

  void fetchUserInterests() async {
    final userDoc = await _firestore.collection('users').doc(user?.uid).get();
    if (userDoc.exists && userDoc.data() != null) {
      setState(() {
        userInterests = List<String>.from(userDoc.data()?['interests'] ?? []);
        print("Interests: $userInterests"); // Debugging print statement
      });
    }
  }

  void fetchLanguages() async {
    final languagesDoc =
    await _firestore.collection('centraldata').doc('languages').get();
    if (languagesDoc.exists && languagesDoc.data() != null) {
      setState(() {
        allLanguages =
        List<String>.from(languagesDoc.data()?['languages'] ?? []);
        print("Languages: $allLanguages"); // Debugging print statement
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Color.fromARGB(255, 148, 98, 214),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SizedBox(height: 20), // Add space above the profile picture
          GestureDetector(
            onTap: uploadProfilePicture,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Color.fromARGB(255, 87, 56, 122),
              backgroundImage: (selectedProfilePicture != null)
                  ? FileImage(selectedProfilePicture!) as ImageProvider<Object>
                  : (profilePictureUrl.isNotEmpty)
                  ? NetworkImage(profilePictureUrl) as ImageProvider<Object>
                  : null,
              child:
              (profilePictureUrl.isEmpty && selectedProfilePicture == null)
                  ? Icon(Icons.add_a_photo, color: Colors.white)
                  : null,
            ),
          ),
          SizedBox(height: 40), // Add space below the profile picture
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            margin: EdgeInsets.only(bottom: 15), // Space between input fields
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Theme(
              data:
              Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                title: Text('Your Interests'),
                textColor: Color.fromARGB(255, 186, 57, 250),
                iconColor: Color.fromARGB(255, 186, 57, 250),
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
                      padding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color.fromARGB(255, 186, 57, 250)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(interest,
                          style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            margin: EdgeInsets.only(bottom: 15), // Space between input fields
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ExpansionTile(
              title: Text('Your Native Language'),
              textColor: Color.fromARGB(255, 186, 57, 250),
              iconColor: Color.fromARGB(255, 186, 57, 250),
              children: (allLanguages.where((language) => language != selectedPreferredLanguage).toList()).map((language) {
                bool isSelected = language == selectedLanguage;
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        selectedLanguage = null; // Deselect the language
                      } else {
                        selectedLanguage = language; // Select the language
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Color.fromARGB(255, 186, 57, 250) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(language, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            margin: EdgeInsets.only(bottom: 15), // Space between input fields
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ExpansionTile(
              title: Text('Preferred Language'),
              textColor: Color.fromARGB(255, 186, 57, 250),
              iconColor: Color.fromARGB(255, 186, 57, 250),
              children: (allLanguages.where((language) => language != selectedLanguage).toList()).map((language) {
                bool isSelected = language == selectedPreferredLanguage;
                return InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        // Nothing happens
                      } else {
                        selectedPreferredLanguage = language; // Select the language
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    margin: EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? Color.fromARGB(255, 186, 57, 250) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(language, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20), // Add space above the save button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Color.fromARGB(255, 186, 57, 250)),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              child: Text('Save changes'),
              onPressed: () async {
                await updateUserProfile(_usernameController.text);
                // Add logic to show a confirmation message
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Color.fromARGB(255, 87, 56, 122), // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}