import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appoitment.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Register User
  Future<AppUser?> registerUser({
    required String name,
    required String email,
    required String password,
    required String role,
    String? specialty,
    String? bio,
    List<String>? availability,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        AppUser user = AppUser(
          uid: firebaseUser.uid,
          name: name,
          email: email,
          role: role,
          profilePicture: 'https://ui-avatars.com/api/?name=$name',
          specialty: specialty,
          bio: bio,
          availability: availability,
        );
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(user.toMap());
        return user;
      }
      return null;
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }

  // Update User
  Future<void> updateUser({
    required String uid,
    String? name,
    String? phone,
    String? specialty,
    String? bio,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (specialty != null) updates['specialty'] = specialty;
      if (bio != null) updates['bio'] = bio;

      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updates);
      }
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  // Login User
  Future<AppUser?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        return getUser(firebaseUser.uid);
      }
      return null;
    } catch (e) {
      print("Error during login: $e");
      return null;
    }
  }

  // Get User
  Future<AppUser?> getUser(String uid) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        return AppUser.fromMap(userDoc.data()!);
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  // Get Users by Role
  Future<List<AppUser>> getUsersByRole(String role) async {
    List<AppUser> users = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();
      for (var doc in querySnapshot.docs) {
        users.add(AppUser.fromMap(doc.data()));
      }
      return users;
    } catch (e) {
      print("Error fetching users by role: $e");
      return users;
    }
  }

  // Get Patient Meetings
  Future<List<Appointment>> getPatientMeetings(String patientId) async {
    List<Appointment> meetings = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('meetings')
          .where('patient_id', isEqualTo: patientId)
          .get();
      for (var doc in querySnapshot.docs) {
        meetings.add(Appointment.fromMap(doc.data()));
      }
      return meetings;
    } catch (e) {
      print("Error fetching patient meetings: $e");
      return meetings;
    }
  }

  // Add Meeting
  Future<bool> addMeeting(Appointment meeting, BuildContext conntext) async {
    List<Appointment> _userMeetings =
        await getPatientMeetings(meeting.patientId!);

    DateTime meetingDate = DateTime.parse(meeting.date!);
    final _acceptedMeetings =
        _userMeetings.where((meet) => meet.status == "Accepted");

    for (var userMeeting in _acceptedMeetings) {
      DateTime date = DateTime.parse(userMeeting.date!);

      if (date.day == meetingDate.day &&
          date.month == meetingDate.month &&
          date.year == meetingDate.year &&
          date.hour == meetingDate.hour) {
        ScaffoldMessenger.of(conntext).showSnackBar(
          const SnackBar(
            content: Text('You already have a meeting at this time.'),
          ),
        );
        return false;
      }
    }
    try {
      await _firestore
          .collection('meetings')
          .doc(meeting.id)
          .set(meeting.toMap());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get Specialist Meetings
  Future<List<Appointment>> getSpecialistMeetings(String specialistId) async {
    List<Appointment> meetings = [];
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('meetings')
          .where('specialist_id', isEqualTo: specialistId)
          .get();
      for (var doc in querySnapshot.docs) {
        meetings.add(Appointment.fromMap(doc.data()));
      }
      return meetings;
    } catch (e) {
      print("Error fetching specialist meetings: $e");
      return meetings;
    }
  }

  // Update Meeting Status
  Future<void> updateMeetingStatus(String meetingId, String status) async {
    try {
      await _firestore
          .collection('meetings')
          .doc(meetingId)
          .update({'status': status});
    } catch (e) {
      print("Error updating meeting status: $e");
    }
  }

  // Update Meeting Status and Report
  Future<void> updateMeetingStatusAndReport(
      String meetingId, String status, String report, String? resume) async {
    try {
      await _firestore.collection('meetings').doc(meetingId).update({
        'status': status,
        'report': report,
        'resume': resume,
      });
    } catch (e) {
      print("Error updating meeting status and report: $e");
    }
  }

  // Update Meeting Status and Meeting URL (Keep existing one if needed elsewhere, or remove if redundant)
  // Future<void> updateMeetingStatusAndMeetingUrl(String meetingId, String status,
  //     String meetingUrl, DateTime meetingDateTime) async {
  //   try {
  //     await _firestore.collection('meetings').doc(meetingId).update({
  //       'status': status,
  //       'meeting_url': meetingUrl,
  //       'date': DateFormat('yyyy-MM-dd').format(meetingDateTime),
  //       'time': DateFormat('HH:mm').format(meetingDateTime),
  //     });
  //   } catch (e) {
  //     print("Error updating meeting status and meeting URL: $e");
  //   }
  // }

  // NEW: Update Meeting Details (Status, URL, Date, Time)
  Future<void> updateMeetingDetails(String meetingId, String status,
      String meetingUrl, String date, String time) async {
    try {
      await _firestore.collection('meetings').doc(meetingId).update({
        'status': status,
        'meeting_url': meetingUrl,
        'date': date, // Already formatted string
        'time': time, // Already formatted string
      });
    } catch (e) {
      print("Error updating meeting details: $e");
      // Re-throw the error so the calling function can handle it (e.g., show a SnackBar)
      throw e;
    }
  }

  // Create User in Firestore after Google Sign Up
  Future<void> createUser(AppUser user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print("Error creating user: $e");
    }
  }

  // Save Test Result
  Future<void> saveTestResult({
    required String userId,
    required String testType,
    required DateTime dateTime,
    required int result,
  }) async {
    try {
      await _firestore.collection('test_saves').doc().set({
        'userId': userId,
        'testType': testType,
        'dateTime': dateTime,
        'result': result,
      });
    } catch (e) {
      print("Error saving test result: $e");
    }
  }

  // Update Meeting Date and Time
  Future<void> updateMeetingDateTime(
      String meetingId, String formattedDateTime) async {
    try {
      DateTime dateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(formattedDateTime);
      await _firestore.collection('meetings').doc(meetingId).update({
        'date': DateFormat('yyyy-MM-dd').format(dateTime),
        'time': DateFormat('HH:mm').format(dateTime),
      });
    } catch (e) {
      print("Error updating meeting date and time: $e");
    }
  }
}
