import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_applicatione/screens/patient/feed.dart';
import 'profile_tab.dart';
import 'specialist_list_tab.dart';
import 'meetings_tab.dart';
import 'activities_tab.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  _PatientHomeScreenState createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    FeedScreen(),
    SpecialistListTab(),
    ActivitiesTab(), // Added ActivitiesTab here
    ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home), //icon for specialists
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.heart_fill), //icon for specialists
            label: 'Specialists',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity), //icon for activities
            label: 'Activities',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
