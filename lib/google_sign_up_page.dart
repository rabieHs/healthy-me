import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart'; // Import FirestoreService
import '../models/user_model.dart'; // Import AppUser
import '../screens/admin/admin_home_screen.dart'; // Import AdminHomeScreen
import '../screens/specialist/specialist_home_screen.dart'; // Import SpecialistHomeScreen
import '../screens/patient/patient_home_screen.dart'; // Import PatientHomeScreen

class GoogleSignUpPage extends StatefulWidget {
  final User? firebaseUser;

  GoogleSignUpPage({Key? key, required this.firebaseUser}) : super(key: key);

  @override
  _GoogleSignUpPageState createState() => _GoogleSignUpPageState();
}

class _GoogleSignUpPageState extends State<GoogleSignUpPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _role = 'patient'; // Default role

  @override
  void initState() {
    super.initState();
    // Pre-fill name from Firebase user data if available
    if (widget.firebaseUser != null &&
        widget.firebaseUser!.displayName != null) {
      _nameController.text = widget.firebaseUser!.displayName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your phone number'
                    : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter your address'
                    : null,
              ),
              DropdownButtonFormField<String>(
                value: _role,
                decoration: InputDecoration(labelText: 'Role'),
                items: <String>['patient', 'specialist', 'admin']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _registerUser(context);
                },
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser(BuildContext context) async {
    // 1. Get user details from controllers and role
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String address = _addressController.text.trim();
    String email = widget.firebaseUser?.email ?? ''; // Use Google email
    String uid = widget.firebaseUser?.uid ?? ''; // Use Firebase UID

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      setState(() {
        // Show error message if any field is empty
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ));
      });
      return;
    }

    // 2. Create AppUser object
    AppUser newUser = AppUser(
      uid: uid,
      name: name,
      email: email,
      phone: phone,
      address: address,
      role: _role,
      profilePicture: widget.firebaseUser?.photoURL ??
          'https://ui-avatars.com/api/?name=$name', // Default profile picture
    );

    // 3. Call FirestoreService to add user
    final FirestoreService _firestoreService = FirestoreService();
    try {
      await _firestoreService.createUser(newUser);
      // 4. Navigate to home screen based on role
      _navigateToHomeScreen(context, _role);
    } catch (e) {
      // Handle registration error
      print("Error registering user: $e");
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to register user. Please try again.'),
          backgroundColor: Colors.red,
        ));
      });
    }
  }

  void _navigateToHomeScreen(BuildContext context, String role) {
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
}
