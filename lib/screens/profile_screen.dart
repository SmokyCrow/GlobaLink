import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _usernameController = TextEditingController();
  List<String> userInterests = [];
  String newInterest = '';

  Future updateUserProfile(String newUsername) async {
    if (user != null) {
      await _firestore.collection('users').doc(user!.uid).update({
        'username': newUsername,
        'interests': userInterests,
      });
      newInterest = '';
    }
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _firestore.collection('users').doc(user!.uid).get().then((doc) {
        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          _usernameController.text = data['username'] ?? '';
        }
      });
      fetchUserInterests();
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
          CircleAvatar(
            radius: 60, // Adjust the size of the profile picture
            backgroundColor:
                Color.fromARGB(255, 87, 56, 122), // Placeholder color
            child: IconButton(
              color: Colors.white,
              icon: Icon(Icons.add),
              onPressed: () {
                // TODO: Implement profile picture change
              },
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
                children: userInterests
                    .map((interest) => ListTile(title: Text(interest)))
                    .toList()
                  ..add(
                    ListTile(
                      title: TextField(
                        onChanged: (value) {
                          newInterest = value;
                        },
                        onSubmitted: (String value) async {
                          if (value.isNotEmpty) {
                            setState(() {
                              userInterests.add(value);
                              newInterest = '';
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Add new interest',
                          labelStyle: TextStyle(color: Color.fromARGB(255, 186, 57, 250)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Color.fromARGB(255, 87, 56, 122)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Color.fromARGB(255, 87, 56, 122)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Color.fromARGB(255, 87, 56, 122)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                        ),
                      ),
                    ),
                  ),
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
            child: ListTile(
              title: Text('Your native language'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: () {
                // TODO: Implement navigation to native language selection
              },
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
            child: ListTile(
              title: Text('Your preferred languages'),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: () {
                // TODO: Implement navigation to preferred languages selection
              },
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
                primary:
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
