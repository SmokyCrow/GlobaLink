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
  final PageController _pageController = PageController();

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
      final DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      // If the profile is incomplete or userData is null, force navigation to the ProfileScreen
      if (userData == null || userData['profileComplete'] != true) {
        _navigateToProfileScreen();
      } else {
        setState(() {
          _isProfileComplete = true;
        });
      }
    }
  }

  void _navigateToProfileScreen() {
    setState(() {
      _currentIndex = 2; // Index of the ProfileScreen
    });
    _pageController.jumpToPage(2);
  }


  @override
  void dispose() {
    // Don't forget to dispose the controller when the state object is removed.
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      // Use a PageView.builder to create pages on demand
      body: PageView.builder(
        // Control the page view with the page controller
        controller: _pageController,
        // Disable page swiping
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          // Return the page based on the current index
          return _pages[index];
        },
        // Set the itemCount to the length of your pages
        itemCount: _pages.length,
        // Update the currentIndex when the page changes
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
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
    checkProfileCompletion();
    // Your existing onTabTapped method
    // If the profile is incomplete, do not navigate away from the ProfileScreen
    if (_isProfileComplete || index == 2) {
      setState(() {
        _currentIndex = index;
      });
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showProfileIncompleteDialog();
    }
  }

  void _showProfileIncompleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Profile Incomplete'),
          content: Text('Please complete your profile.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToProfileScreen();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

