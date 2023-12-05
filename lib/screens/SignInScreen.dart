import 'package:flutter/material.dart';

class SignInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Sign in" Text and Picture
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // "Sign in" Text
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: EdgeInsets.only(left: 65.0),
                    child: Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ),

                // Picture
                Expanded(
                  flex: 2,
                  child: Image.asset(
                    'images/signin_image.png',
                    height: MediaQuery.of(context).size.height / 3, // 1/3 of screen height
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Username or E-mail TextField
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Username or E-mail',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Password TextField
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 32),

            // Sign In Button
            ElevatedButton(
              onPressed: () {
                // Add sign-in logic here
              },
              child: Text('Sign In'),
            ),
            SizedBox(height: 16),

            // Back to Welcome Button
            TextButton(
              onPressed: () {
                // Navigate back to Welcome screen
                Navigator.pop(context);
              },
              child: Text('Don\'t have an account yet?'),
            ),
          ],
        ),
      ),
    );
  }
}