import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'package:flutter_applicatione/screens/admin/admin_home_screen.dart';
import 'package:flutter_applicatione/screens/specialist/specialist_home_screen.dart';
import 'package:flutter_applicatione/screens/patient/patient_home_screen.dart';
import 'google_sign_up_page.dart'; // Import the new sign-up page

import 'forget_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      AppUser? user = await _firestoreService.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (user != null) {
        _navigateToHomeScreen(context, user.role);
      } else {
        setState(() {
          _errorMessage = 'Login failed. Invalid credentials.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during login.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _googleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _errorMessage = 'Google Sign-in cancelled by user.';
        });
        return;
      }

      final GoogleSignInAuthentication? googleAuth =
          await googleUser.authentication;
      if (googleAuth == null) {
        setState(() {
          _errorMessage = 'Failed to get Google Sign-in authentication.';
        });
        return;
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        AppUser? user = await _firestoreService.getUser(firebaseUser.uid);
        if (user != null) {
          _navigateToHomeScreen(context, user.role);
        } else {
          // Navigate to GoogleSignUpPage if user data not found
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  GoogleSignUpPage(firebaseUser: firebaseUser),
            ),
          );
          return;
        }
      } else {
        setState(() {
          _errorMessage = 'Firebase sign-in with Google failed.';
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        _errorMessage = 'Error during Google Sign-in: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToHomeScreen(BuildContext context, String? role) {
    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminHomeScreen()),
      );
    } else if (role == 'specialist') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SpecialistHomeScreen()),
      );
    } else if (role == 'patient') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PatientHomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          if (_errorMessage.isNotEmpty)
            Text(_errorMessage, style: TextStyle(color: Colors.red)),
          SizedBox(height: 20),
          _isLoading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _googleSignIn,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.android),
                SizedBox(width: 10),
                Text('Sign in with Google'),
              ],
            ),
          ),
          SizedBox(height: 10),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ForgetPasswordPage()),
              );
            },
            child: Text('Forgot Password?'),
          ),
        ],
      ),
    );
  }
}
