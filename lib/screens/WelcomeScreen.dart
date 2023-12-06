import 'package:flutter/material.dart';

import 'SignInScreen.dart';
import 'SignUpScreen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image
                Image.asset(
                  'images/welcome_page.png',
                  height: 200, // Adjust the height as needed
                  fit: BoxFit.cover,
                ),
                SizedBox(height: 8),

                // Introduction Text
                Text(
                  'Welcome to GlobaLink',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Explore the world and connect with people globally.',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 280),

                // Sign In Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignInScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent, // Change the button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // Adjust the button border radius
                    ),
                    minimumSize: Size(20, 45)
                  ),
                  child: Text('Sign In'),
                ),
                SizedBox(height: 16),

                // Sign Up Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0), // Adjust the button border radius
                    ),
                      fixedSize: Size(20, 45)
                  ),
                  child: Text('Sign Up', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
