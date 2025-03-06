import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_page.dart';
import 'screens/welcome/welcomescreen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/specialist/specialist_home_screen.dart';
import 'screens/patient/patient_home_screen.dart';
import 'services/firestore_service.dart'; // Import FirestoreService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDxfFlB9QCkg-uCpOy8cAa0x88j7arF4IA",
      authDomain: "healthyme-4b7e0.firebaseapp.com",
      projectId: "healthyme-4b7e0",
      storageBucket: "healthyme-4b7e0.firebasestorage.app",
      messagingSenderId: "51766395888",
      appId: "1:51766395888:android:d5ed014c76e195136ed335",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _homePage = const WelcomeScreen();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final appUser = await _firestoreService.getUser(user.uid);
      if (appUser != null) {
        setState(() {
          if (appUser.role == 'patient') {
            _homePage = const PatientHomeScreen();
          } else if (appUser.role == 'specialist') {
            _homePage = const SpecialistHomeScreen();
          } else if (appUser.role == 'admin') {
            _homePage = const AdminHomeScreen();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: _homePage,
    );
  }
}
