// import 'package:flutter/material.dart';
// import 'signin_screen.dart'; // make sure to import your sign-in screen
//
// class WelcomeScreen extends StatelessWidget {
//   const WelcomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('images/background.png'), // Your background image
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Spacer(),
//             Image.asset(
//               'images/welcome_page.png', // Your welcome graphic
//               height: 300, // Adjust the size as needed
//             ),
//             const Text(
//               'Welcome to GlobaLink',
//               style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               textAlign: TextAlign.center,
//             ),
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 48, vertical: 10),
//               child: Text(
//                 'Explore the world and connect with people globally.',
//                 style: TextStyle(fontSize: 18),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//             const Spacer(),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 10),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                     foregroundColor: Colors.white, backgroundColor: const Color(0xFF9562D8), // Text color
//                     minimumSize: const Size(double.infinity, 50) // Full width button
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => SignInScreen()),
//                   );
//                 },
//                 child: const Text('Continue'),
//               ),
//             ),
//             const Spacer(),
//           ],
//         ),
//       ),
//     );
//   }
// }
