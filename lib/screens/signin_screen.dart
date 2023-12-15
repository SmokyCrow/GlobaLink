// import 'package:flutter/material.dart';
// import 'package:globalink/services/auth/auth_service.dart';
// import 'package:provider/provider.dart';
//
// class SignInScreen extends StatefulWidget {
//   final void Function()? onTap;
//   const SignInScreen({super.key, required this.onTap});
//
//   @override
//   State<SignInScreen> createState() => _SignInScreenState();
// }
//
// class _SignInScreenState extends State<SignInScreen> {
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   void signIn() async {
//     final authService = Provider.of<AuthService>(context, listen: false);
//     try {
//       await authService.signInWithEmailAndPassword(
//           emailController.text, passwordController.text);
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text(e.toString())));
//     }
//   }
//   final FocusNode emailFocus = FocusNode();
//   final FocusNode passwordFocus = FocusNode();
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Add listeners to the FocusNode of each text field
//     emailFocus.addListener(_onEmailFocusChange);
//     passwordFocus.addListener(_onPasswordFocusChange);
//   }
//
//   bool isEmailFocused = false;
//   bool isPasswordFocused = false;
//
//   // Define callback functions for focus changes
//   void _onEmailFocusChange() {
//     setState(() {
//       isEmailFocused = emailFocus.hasFocus;
//     });
//   }
//
//   void _onPasswordFocusChange() {
//     setState(() {
//       isPasswordFocused = passwordFocus.hasFocus;
//     });
//   }
//
//   @override
//   void dispose() {
//     // Dispose of the FocusNode listeners when the widget is disposed
//     emailFocus.dispose();
//     passwordFocus.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
//
//     // Calculate the available screen height when the keyboard is open
//     final availableScreenHeight = screenHeight - keyboardHeight;
//
//     return Scaffold(
//       resizeToAvoidBottomInset: false,
//       body: Container(
//         height: screenHeight, // Set a fixed height for the background image
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/background.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SingleChildScrollView(
//           reverse: true, // Ensure the text fields stay above the keyboard
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const SizedBox(height: 64),
//               // Image
//               Image.asset(
//                 'images/welcome_page.png',
//                 height: 200, // Adjust the height as needed
//                 fit: BoxFit.cover,
//               ),
//               const SizedBox(height: 8),
//
//               // Introduction Text with increased padding
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0), // Increased horizontal padding
//                 child: Column(
//                   children: [
//                     const Text(
//                       'Welcome to GlobaLink',
//                       style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 12),
//                     const Text(
//                       'Explore the world and connect with people globally.',
//                       style: TextStyle(fontSize: 20),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(height: 50),
//
//               // Wrap the text fields and button inside a Container with increased padding
//               Container(
//                 padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, (isEmailFocused || isPasswordFocused) ? 0 : 96), // Adjust padding based on text field focus
//                 child: ListView(
//                   shrinkWrap: true, // Ensure the ListView takes up only as much space as needed
//                   children: [
//                     // Username or E-mail TextField
//                     TextFormField(
//                       focusNode: emailFocus, // Assign the focus node
//                       controller: emailController,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Color.fromARGB(255, 149, 98, 216), width: 2.0),
//                           borderRadius: BorderRadius.circular(30.0),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Color.fromARGB(255, 149, 98, 216), width: 2.0),
//                           borderRadius: BorderRadius.circular(30.0),
//                         ),
//                         labelText: 'Username or E-mail',
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Password TextField
//                     TextFormField(
//                       focusNode: passwordFocus, // Assign the focus node
//                       controller: passwordController,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white,
//                         enabledBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Color.fromARGB(255, 149, 98, 216), width: 2.0),
//                           borderRadius: BorderRadius.circular(30.0),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(
//                               color: Color.fromARGB(255, 149, 98, 216), width: 2.0),
//                           borderRadius: BorderRadius.circular(30.0),
//                         ),
//                         labelText: 'Password',
//                         border: OutlineInputBorder(),
//                       ),
//                       obscureText: true,
//                     ),
//                     const SizedBox(height: 32),
//
//                     // Sign In Button
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         primary: Color(0xFF9562D8),
//                         onPrimary: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(30.0),
//                         ),
//                       ),
//                       onPressed: signIn,
//                       child: const Text('Sign In'),
//                     ),
//                     const SizedBox(height: 16),
//
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Text("Not a member?"),
//                         const SizedBox(width: 4),
//                         GestureDetector(
//                           onTap: widget.onTap,
//                           child: const Text(
//                             "Sign Up",
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


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


    final authService = Provider.of<AuthService>(context, listen: false);
    User? user = (await authService.signInWithEmailAndPassword(data.name, data.password)) as User?;
    if (user == null) {
      return 'Email or password is incorrect';
    }
    return null;
  }

  Future<String?> _signupUser(SignupData data, BuildContext context) async {
    if (data.name == null || data.password == null) {
      return 'Email and password cannot be empty';
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    User? user = (await authService.signUpWithEmailAndPassword(data.name!, data.password!)) as User?;
    if (user == null) {
      return 'Failed to create an account';
    }
    return null;
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

