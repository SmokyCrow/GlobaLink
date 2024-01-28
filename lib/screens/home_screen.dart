import 'dart:async';

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
  int _currentIndex = 0;
  bool _isProfileComplete = false;
  bool _isLoading = true;

  late Future<void> _profileCheckFuture;

  final List<Widget> _pages = [
    RoomsScreen(),
    UsersScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _profileCheckFuture = checkProfileCompletion();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> checkProfileCompletion() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;
      setState(() {
        _isProfileComplete = userData?['profileComplete'] ?? false;
        if (!_isProfileComplete) {
          _currentIndex = 2;
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
        child: _isLoading
            ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
            : FutureBuilder<void>(
          future: _profileCheckFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return _pages[_currentIndex];
            }
          },
          key: const ValueKey('content'),
        ),
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
    if (_isProfileComplete || index == 2) {
      setState(() {
        _currentIndex = index;
      });
    } else {
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