import 'package:flutter/material.dart';
import 'package:globalink/auth/auth_service.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  final void Function()? onTap;
  const SignInScreen({super.key, required this.onTap});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signInWithEmailAndPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    // Add listeners to the FocusNode of each text field
    emailFocus.addListener(_onEmailFocusChange);
    passwordFocus.addListener(_onPasswordFocusChange);
  }

  bool isEmailFocused = false;
  bool isPasswordFocused = false;

  // Define callback functions for focus changes
  void _onEmailFocusChange() {
    setState(() {
      isEmailFocused = emailFocus.hasFocus;
    });
  }

  void _onPasswordFocusChange() {
    setState(() {
      isPasswordFocused = passwordFocus.hasFocus;
    });
  }

  @override
  void dispose() {
    // Dispose of the FocusNode listeners when the widget is disposed
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Calculate the available screen height when the keyboard is open
    final availableScreenHeight = screenHeight - keyboardHeight;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        height: screenHeight, // Set a fixed height for the background image
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          reverse: true, // Ensure the text fields stay above the keyboard
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              // Image
              Image.asset(
                'images/welcome_page.png',
                height: 200, // Adjust the height as needed
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),

              // Introduction Text with increased padding
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Increased horizontal padding
                child: Column(
                  children: [
                    const Text(
                      'Welcome to GlobaLink',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Explore the world and connect with people globally.',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              // Wrap the text fields and button inside a Container with increased padding
              Container(
                padding: EdgeInsets.fromLTRB(16.0, 0, 16.0, (isEmailFocused || isPasswordFocused) ? 0 : 96), // Adjust padding based on text field focus
                child: ListView(
                  shrinkWrap: true, // Ensure the ListView takes up only as much space as needed
                  children: [
                    // Username or E-mail TextField
                    TextFormField(
                      focusNode: emailFocus, // Assign the focus node
                      controller: emailController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 149, 98, 216), width: 2.0),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 149, 98, 216), width: 2.0),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        labelText: 'Username or E-mail',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password TextField
                    TextFormField(
                      focusNode: passwordFocus, // Assign the focus node
                      controller: passwordController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 149, 98, 216), width: 2.0),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromARGB(255, 149, 98, 216), width: 2.0),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 32),

                    // Sign In Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFF9562D8),
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      onPressed: signIn,
                      child: const Text('Sign In'),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Not a member?"),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
