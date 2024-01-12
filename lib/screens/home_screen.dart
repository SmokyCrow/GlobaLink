import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:globalink/screens/profile_screen.dart';
import 'package:globalink/screens/rooms_screen.dart';
import 'package:globalink/screens/users_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // To keep track of the current index
  bool _isProfileComplete = false;

  // Pages to navigate between
  final List<Widget> _pages = [
    RoomsScreen(), // Replace with your RoomsScreen widget
    UsersScreen(), // Replace with your UsersScreen widget
    ProfileScreen(), // Already defined in your code
  ];

  @override
  void initState() {
    super.initState();
    checkProfileCompletion(); // Check if the profile is complete when the widget is created
  }

  void checkProfileCompletion() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      setState(() {
        _isProfileComplete = userData?['profileComplete'] ?? false;
        if (!_isProfileComplete) {
          // If the profile is not complete, force the current index to the profile tab
          _currentIndex = 2; // Assuming the ProfileScreen is at index 2
        }
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: _pages[_currentIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Rooms',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'New Chat',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile'
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) async{
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      setState(() {
        _isProfileComplete = userData?['profileComplete'] ?? false;
      });
    }
    print(_isProfileComplete);
    if (_isProfileComplete || index == 2) { // Assuming index 2 is for ProfileScreen
      setState(() {
        _currentIndex = index;
      });
    } else {
      // Optionally show a dialog/message to the user indicating they need to complete their profile
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Profile Incomplete'),
            content: Text('Please complete your profile.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}