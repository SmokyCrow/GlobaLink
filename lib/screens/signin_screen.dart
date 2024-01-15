import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:provider/provider.dart';

import '../services/auth/auth_service.dart';
import 'home_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data, BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signInWithEmailAndPassword(data.name, data.password);
      // If signInWithEmailAndPassword is successful, the function will continue below.
      return null; // Return null to indicate success
    } catch (e) {
      // Handle any other exceptions that might occur.
      return 'Wrong Email or Password';
    }
  }

  Future<String?> _signupUser(SignupData data, BuildContext context) async {
    if (data.name == null || data.password == null) {
      return 'Email and password cannot be empty';
    }

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      UserCredential userCredential = await authService
          .signUpWithEmailAndPassword(data.name!, data.password!);
      User? user = userCredential.user;
      if (user == null) {
        return 'Failed to create an account';
      }
      // Continue with the user object...
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message; // Returning the error message from FirebaseAuth
    }
  }

  Future<String?> _recoverPassword(String name, BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.sendPasswordResetEmail(name);
      return null; // Return null to indicate success
    } catch (e) {
      return 'Error sending password reset email'; // Return a string message in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: 'GlobaLink',
      logo: const AssetImage('images/welcome_page.png'),
      onLogin: (data) => _authUser(data, context),
      onSignup: (data) => _signupUser(data, context),
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ));
      },
      onRecoverPassword: (name) => _recoverPassword(name, context),
      theme: LoginTheme(
        primaryColor: Colors.lightBlue[700],
        accentColor: Colors.lightBlueAccent,
        errorColor: Colors.redAccent,
        pageColorLight: Colors.lightBlue[50],
        pageColorDark: Colors.blueGrey[900],
        titleStyle: TextStyle(
          color: Colors.blue.shade900,
          fontFamily: 'Quicksand',
          letterSpacing: 2,
        ),
        // TextField style
        textFieldStyle: TextStyle(
          color: Colors.blueGrey.shade800,
          shadows: [Shadow(color: Colors.blue.shade100, blurRadius: 2)],
        ),
        // Button Theme
        buttonTheme: LoginButtonTheme(
          backgroundColor: Colors.blue.shade800,
          highlightColor: Colors.blue.shade600,
          splashColor: Colors.blue.shade400,
          elevation: 5.0,
          highlightElevation: 4.0,
        ),
        // Input Theme
        inputTheme: InputDecorationTheme(
          // ... other properties
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.blue.shade800),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.0),
            borderSide: BorderSide(color: Colors.blue.shade500),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.blue.shade700),
          ),
          labelStyle: TextStyle(color: Colors.blue[800]),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
