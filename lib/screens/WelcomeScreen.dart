import 'package:flutter/material.dart';

import 'SignInScreen.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Image.asset(
              'images/welcome_page.jpg',
              height: 200, // Adjust the height as needed
              fit: BoxFit.cover,
            ),
            SizedBox(height: 16),

            // Introduction Text
            Text(
              'Welcome to GlobaLink',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Explore the world with GlobaLink and connect with people globally.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),

            // Sign In Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                );
              },
              child: Text('Sign In'),
            ),
            SizedBox(height: 16),

            // Sign Up Button
            OutlinedButton(
              onPressed: () {
                // Add sign-up navigation logic here
              },
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
