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
  late int _currentIndex = 0; // To keep track of the current index
  bool _isProfileComplete = false;

  // Pages to navigate between
  final List<Widget> _pages = [
    RoomsScreen(),
    UsersScreen(),
    ProfileScreen(),
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
        if (_isProfileComplete) {
          _currentIndex = 0; // If the profile is complete, switch to RoomsScreen
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        selectedItemColor: Colors.blue.shade900,
        unselectedItemColor: Colors.grey,
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
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      setState(() {
        _isProfileComplete = userData?['profileComplete'] ?? false;
      });
    }
    print(_isProfileComplete);
    if (_isProfileComplete || index == 2) {
      setState(() {
        _currentIndex = index;
      });
    } else {
      // Optionally show a dialog/message to the user indicating they need to complete their profile
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Profile Incomplete'),
            content: const Text('Please complete your profile.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
