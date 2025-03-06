import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'package:flutter_applicatione/screens/admin/admin_home_screen.dart';
import 'package:flutter_applicatione/screens/specialist/specialist_home_screen.dart';
import 'package:flutter_applicatione/screens/patient/patient_home_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firestoreService = FirestoreService();
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
        ],
      ),
    );
  }
}
