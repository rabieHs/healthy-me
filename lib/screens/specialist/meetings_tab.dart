import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/appoitment.dart';
import '../../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/analyse_serices.dart'; // Import AnalyseServices
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingsTab extends StatefulWidget {
  const MeetingsTab({Key? key}) : super(key: key);

  @override
  _MeetingsTabState createState() => _MeetingsTabState();
}

class _MeetingsTabState extends State<MeetingsTab> {
  final FirestoreService _firestoreService = FirestoreService();
  final AnalyseServices _analyseServices =
      AnalyseServices(); // Initialize AnalyseServices
  List<Appointment> _meetings = [];

  @override
  void initState() {
    super.initState();
    _loadMeetings();
  }

  _loadMeetings() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      List<Appointment> meetings =
          await _firestoreService.getSpecialistMeetings(user.uid);
      setState(() {
        _meetings = meetings;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _meetings.isEmpty
        ? const Center(child: Text('No meetings scheduled.'))
        : ListView.builder(
            itemCount: _meetings.length,
            itemBuilder: (context, index) {
              final meeting = _meetings[index];
              return FutureBuilder<DocumentSnapshot?>(
                // FutureBuilder to fetch test result
                future:
                    _analyseServices.getLatestTestResult(meeting.patientId!),
                builder: (context, testSnapshot) {
                  String testType = 'N/A';
                  String testMood = 'N/A';
                  String testDate = 'N/A';

                  if (testSnapshot.connectionState == ConnectionState.done) {
                    if (testSnapshot.hasData && testSnapshot.data != null) {
                      final testData =
                          testSnapshot.data!.data() as Map<String, dynamic>?;
                      print("testData: $testData");
                      if (testData != null) {
                        testType = testData['type'] as String? ?? 'N/A';
                        testMood = testData['mood'] as String? ?? 'N/A';
                        Timestamp timestamp =
                            testData['date'] as Timestamp? ?? Timestamp.now();
                        DateTime dateTime = timestamp.toDate();
                        testDate =
                            DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
                      }
                    }
                  }

                  return GestureDetector(
                    onTap: meeting.status == 'Accepted'
                        ? () {
                            _showReportDialog(context, meeting);
                          }
                        : null,
                    child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FutureBuilder<AppUser?>(
                              future:
                                  _firestoreService.getUser(meeting.patientId!),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return const Text('Patient Name: N/A');
                                }
                                final patient = snapshot.data!;
                                return Text(
                                  'Meeting with ${patient.name ?? 'N/A'}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Text('Date: ${meeting.date}'),
                            Text('Time: ${meeting.time}'),
                            Text('Status: ${meeting.status}'),
                            Text('Type: $testType'),
                            Text('Mood: $testMood'),
                            Text('Test Date: $testDate'),
                            if (meeting.status ==
                                "Accepted") // Conditionally display test result if meeting is accepted
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Latest Test Result:',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text('Type: $testType'),
                                  Text('Mood: $testMood'),
                                  Text('Date: $testDate'),
                                ],
                              ),
                            meeting.status == "Pending"
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      ElevatedButton(
                                        onPressed: () {
                                          _updateMeetingStatus(
                                              meeting.id, 'Accepted');
                                        },
                                        child: const Text('Accept'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          _updateMeetingStatus(
                                              meeting.id, 'Rejected');
                                        },
                                        child: const Text('Reject'),
                                      ),
                                    ],
                                  )
                                : const Text(""),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
  }

  Future<void> _updateMeetingStatus(String? meetingId, String status) async {
    if (meetingId != null) {
      if (status == 'Accepted') {
        TextEditingController meetingUrlController = TextEditingController();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Enter Meeting URL'),
              content: TextField(
                controller: meetingUrlController,
                decoration: const InputDecoration(
                  hintText: 'Meeting URL',
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Accept'),
                  onPressed: () async {
                    String meetingUrl = meetingUrlController.text;
                    if (meetingUrl.isNotEmpty) {
                      try {
                        await _firestoreService
                            .updateMeetingStatusAndMeetingUrl(
                                meetingId, status, meetingUrl);
                        // Refresh meetings list after status update
                        _loadMeetings();
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      } catch (e) {
                        print('Error updating meeting status: $e');
                        // Handle error, e.g., show a snackbar
                      }
                    } else {
                      // Show error message if meeting URL is empty
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Meeting URL cannot be empty.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      } else {
        try {
          await _firestoreService.updateMeetingStatus(meetingId, status);
          // Refresh meetings list after status update
          _loadMeetings();
        } catch (e) {
          print('Error updating meeting status: $e');
          // Handle error, e.g., show a snackbar
        }
      }
    }
  }

  void _showReportDialog(BuildContext context, Appointment meeting) {
    TextEditingController reportController = TextEditingController();
    TextEditingController resumeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Meeting Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 20),
                TextField(
                  controller: resumeController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Enter meeting resume',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: reportController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Enter meeting report',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Complete Meeting'),
              onPressed: () async {
                String report = reportController.text;
                String resume = resumeController.text;
                if (report.isNotEmpty && resume.isNotEmpty) {
                  await _firestoreService.updateMeetingStatusAndReport(
                    meeting.id!,
                    'Completed',
                    report,
                    resume,
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                  // Refresh meetings list
                  _loadMeetings();
                } else {
                  // Show error message if report is empty
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report and resume cannot be empty.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
