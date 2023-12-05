import 'package:flutter/material.dart';

import 'SignInScreen.dart';

class SignUpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "Sign up" Text and Picture
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "Sign up" Text
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: EdgeInsets.only(left: 65.0),
                      child: Text(
                        'Sign up',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),

                  // Picture (You can replace this with your image)
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'images/signup_image.png',
                      height: MediaQuery.of(context).size.height / 3, // 1/3 of screen height
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Full Name TextField
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Username TextField
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Email TextField
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'E-mail',
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

              // Sign Up Button
              ElevatedButton(
                onPressed: () {
                  // Add sign-up logic here
                },
                child: Text('Sign Up'),
              ),
              SizedBox(height: 16),

              // Already have an account? Login Button
              TextButton(
                onPressed: () {
                  // Navigate back to Welcome screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                  );
                },
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}