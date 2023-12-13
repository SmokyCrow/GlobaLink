import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:globalink/screens/signin_page.dart';
import 'package:globalink/screens/signup_screen.dart';

class SigninOrSignup extends StatefulWidget {
  const SigninOrSignup ({super.key});

  @override
  State<SigninOrSignup> createState() => _SigninOrSignupState();
}

class _SigninOrSignupState extends State<SigninOrSignup> {
  bool showSignin = true;

  void togglePages(){
    setState((){
      showSignin = !showSignin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(showSignin){
      return SignInScreen(onTap: togglePages);
    } else {
      return SignUpScreen(onTap: togglePages);
    }
  }
}
