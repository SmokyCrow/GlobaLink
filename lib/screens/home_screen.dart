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

  // Future to represent the profile completion check
  late Future<void> _profileCheckFuture;

  // Pages to navigate between
  final List<Widget> _pages = [
    RoomsScreen(), // Replace with your RoomsScreen widget
    UsersScreen(), // Replace with your UsersScreen widget
    const ProfileScreen(), // Already defined in your code
  ];

  @override
  void initState() {
    super.initState();
    _profileCheckFuture = checkProfileCompletion(); // Check if the profile is complete when the widget is created
  }

  Future<void> checkProfileCompletion() async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: FutureBuilder<void>(
        future: _profileCheckFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while the profile check is in progress.
            return const Center(child: CircularProgressIndicator(color: Color.fromARGB(255, 17, 71, 160),));
          } else {
            // If the profile is complete, build the screen.
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 700),
              child: _pages[_currentIndex],
            );
          }
        },
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