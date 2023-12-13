import 'package:flutter/material.dart';
import 'package:globalink/auth/auth_service.dart';
import 'package:provider/provider.dart';


class SignInScreen extends StatefulWidget{
  final void Function()? onTap;
  const SignInScreen({super.key, required this.onTap});

  @override
  State<SignInScreen> createState() => _SignInScreenState();

}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signIn() async{
    final authService = Provider.of<AuthService>(context, listen: false);
    try{
      await authService.signInWithEmailAndPassword(
          emailController.text,
          passwordController.text
      );
    }
    catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
              const SizedBox(height: 64),
              // Image
              Image.asset(
                'images/welcome_page.png',
                height: 200, // Adjust the height as needed
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 8),

              // Introduction Text
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
              const SizedBox(height: 80),

              // Username or E-mail TextField
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Username or E-mail',
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

              // Sign In Button
              ElevatedButton(
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
                          )
                      )
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}