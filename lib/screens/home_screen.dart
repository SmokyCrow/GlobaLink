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

  // Pages to navigate between
  final List<Widget> _pages = [
    const RoomsScreen(), // Replace with your RoomsScreen widget
    UsersScreen(), // Replace with your UsersScreen widget
    ProfileScreen(), // Already defined in your code
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: const Text('Rooms'),
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
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

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index; // Changing the current index state
    });
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
}