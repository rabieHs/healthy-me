import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  Future<void> addMeeting(Appointment meeting) async {
    try {
      await _firestore
          .collection('meetings')
          .doc(meeting.id)
          .set(meeting.toMap());
    } catch (e) {
      print("Error adding meeting: $e");
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

  // Update Meeting Status and Meeting URL
  Future<void> updateMeetingStatusAndMeetingUrl(
      String meetingId, String status, String meetingUrl) async {
    try {
      await _firestore.collection('meetings').doc(meetingId).update({
        'status': status,
        'meeting_url': meetingUrl,
      });
    } catch (e) {
      print("Error updating meeting status and meeting URL: $e");
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
}
