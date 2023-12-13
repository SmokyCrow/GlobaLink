import 'package:flutter/material.dart';
import 'package:globalink/auth/auth_service.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget{
  final void Function()? onTap;
  const SignUpScreen({super.key, required this.onTap});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();

}


class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUp() async{

    final authService = Provider.of<AuthService>(context, listen: false);
    
    try{
      await authService.signUpWithEmailAndPassword(
          emailController.text,
          passwordController.text
      );

    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString()),
          ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // "Sign up" Text and Picture
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // "Sign up" Text
                  const Expanded(
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
              const SizedBox(height: 16),

              // Full Name TextField
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Username TextField
              TextFormField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Email TextField
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Password TextField
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),

              // Sign Up Button
              ElevatedButton(
                onPressed: () {
                  signUp();
                },
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 16),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already a member?"),
                  const SizedBox(width: 4),
                  GestureDetector(
                      onTap: widget.onTap,
                      child: const Text(
                          "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          )
                      )
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}