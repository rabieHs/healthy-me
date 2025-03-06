import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'package:flutter_applicatione/screens/admin/admin_home_screen.dart';
import 'package:flutter_applicatione/screens/specialist/specialist_home_screen.dart';
import 'package:flutter_applicatione/screens/patient/patient_home_screen.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _roleController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();
  final _availabilityController = TextEditingController();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  String _errorMessage = '';
  List<String> _roles = ['patient', 'specialist', 'admin']; // Roles dropdown

  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String role = _roleController.text;
    String? specialty = role == 'specialist' ? _specialtyController.text : null;
    String? bio = role == 'specialist' ? _bioController.text : null;
    List<String>? availability =
        role == 'specialist' ? _availabilityController.text.split(',') : null;

    try {
      AppUser? user = await _firestoreService.registerUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: role,
        specialty: specialty,
        bio: bio,
        availability: availability,
      );

      if (user != null) {
        _navigateToHomeScreen(user.role);
      } else {
        setState(() {
          _errorMessage = 'Registration failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred during registration.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToHomeScreen(String? role) {
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
        children: <Widget>[
          SizedBox(
            height: 600.0, // Temporary fixed height for ListView
            child: ListView(
              children: <Widget>[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
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
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: 'Role'),
                  value: _roleController.text.isNotEmpty
                      ? _roleController.text
                      : null,
                  onChanged: (String? newValue) {
                    setState(() {
                      _roleController.text = newValue!;
                    });
                  },
                  items: _roles.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                if (_roleController.text == 'specialist') ...[
                  TextField(
                    controller: _specialtyController,
                    decoration: InputDecoration(labelText: 'Specialty'),
                  ),
                  TextField(
                    controller: _bioController,
                    decoration: InputDecoration(labelText: 'Bio'),
                  ),
                  TextField(
                    controller: _availabilityController,
                    decoration: InputDecoration(
                      labelText: 'Availability (comma-separated)',
                    ),
                  ),
                ],
                SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(_errorMessage, style: TextStyle(color: Colors.red)),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signUp,
                        child: Text('Register'),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
