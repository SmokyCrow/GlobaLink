import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:globalink/screens/profile_screen.dart';
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
      UserCredential userCredential = await authService.signUpWithEmailAndPassword(data.name!, data.password!);
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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/background.png"),
          fit: BoxFit.cover,
        ),
      ),

      child: FlutterLogin(
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
          primaryColor: Color.fromARGB(255, 149, 98, 216),
          accentColor: Colors.white,
          errorColor: Colors.deepOrange,
          pageColorLight: Colors.transparent,
          pageColorDark: Colors.transparent,
          titleStyle: const TextStyle(
            color: Color.fromARGB(255, 149, 98, 216),
            fontFamily: 'Quicksand',
            letterSpacing: 4,
          ),
          // TextField style
          textFieldStyle: const TextStyle(
            color: Colors.black,
            shadows: [Shadow(color: Colors.yellow, blurRadius: 2)],
          ),
          // Button Theme
          buttonTheme: const LoginButtonTheme(
            backgroundColor: Color.fromARGB(255, 149, 98, 216),
            highlightColor: Color.fromARGB(255, 149, 98, 216),
            splashColor: Colors.purpleAccent,
            elevation: 9.0,
            highlightElevation: 6.0,
          ),
          // Input Theme
          inputTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.purple.withOpacity(.1),
            contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Color.fromARGB(255, 149, 98, 216)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide(color: Color.fromARGB(255, 149, 98, 216)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(color: Color.fromARGB(255, 149, 98, 216)),
            ),
            labelStyle: TextStyle(color: Colors.deepPurple.shade700),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide(color: Colors.red.shade700),
            ),
          ),
        ),
      ),
    );
  }
}