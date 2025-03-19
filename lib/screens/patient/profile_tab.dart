import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../screens/welcome/welcomescreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final FirestoreService _firestoreService = FirestoreService();
  AppUser? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  _loadCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUser = await _firestoreService.getUser(user.uid);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(_currentUser!.name ?? 'N/A'),
                    subtitle: const Text('Name'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(_currentUser!.email ?? 'N/A'),
                    subtitle: const Text('Email'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: Text(_currentUser!.phone ?? 'N/A'),
                    subtitle: const Text('Phone'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(_currentUser!.address ?? 'N/A'),
                    subtitle: const Text('Address'),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => WelcomeScreen()),
                        );
                      },
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
