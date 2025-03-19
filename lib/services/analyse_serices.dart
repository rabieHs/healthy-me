import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyseServices {
  void checkAndUpdateUserMood(String mood, String type) async {
    await FirebaseFirestore.instance
        .collection("test")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      "type": type,
      "date": DateTime.now(),
      "mood": mood,
    });
  }

  Future<DocumentSnapshot?> getLatestTestResult(String patientUid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("test")
        .where(FieldPath.documentId, isEqualTo: patientUid)
        .orderBy("date", descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first as DocumentSnapshot<Object?>;
    } else {
      return null;
    }
  }
}
