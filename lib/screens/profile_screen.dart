import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Profile'),
        centerTitle: true,
        backgroundColor: Colors.grey[300],
        elevation: 0, // Removes the shadow from the app bar.
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          SizedBox(height: 20), // Add space above the profile picture
          CircleAvatar(
            radius: 60, // Adjust the size of the profile picture
            backgroundColor: Colors.grey, // Placeholder color
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // TODO: Implement profile picture change
              },
            ),
          ),
          SizedBox(height: 40), // Add space below the profile picture
          ListTile(
            title: Text('Your interests'),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: () {
              // TODO: Implement navigation to interests selection
            },
          ),
          ListTile(
            title: Text('Your native language'),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: () {
              // TODO: Implement navigation to native language selection
            },
          ),
          ListTile(
            title: Text('Your preferred languages'),
            trailing: Icon(Icons.arrow_drop_down),
            onTap: () {
              // TODO: Implement navigation to preferred languages selection
            },
          ),
          SizedBox(height: 20), // Add space above the save button
          ElevatedButton(
            child: Text('Save changes'),
            onPressed: () {
              // TODO: Implement save changes logic
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.grey[300], // Background color
              onPrimary: Colors.black, // Text color
            ),
          ),
        ],
      ),
    );
  }
}