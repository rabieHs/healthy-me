import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/appoitment.dart';
import '../../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/analyse_serices.dart'; // Import AnalyseServices
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Ensure Material is imported
import '../../services/firestore_service.dart';
import '../../models/appoitment.dart';
import '../../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/analyse_serices.dart'; // Import AnalyseServices
import 'package:intl/intl.dart';

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

  // Helper function for URL validation
  bool _isValidUrl(String url) {
    // Simple regex for basic URL validation (you might want a more robust one)
    final RegExp urlRegExp = RegExp(
        r"^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$",
        caseSensitive: false,
        multiLine: false);
    return urlRegExp.hasMatch(url);
  }

  Future<void> _updateMeetingStatus(String? meetingId, String status) async {
    if (meetingId == null) return;

    if (status == 'Accepted') {
      _showEnterUrlDialog(meetingId, status);
    } else {
      // Handle rejection directly
      try {
        await _firestoreService.updateMeetingStatus(meetingId, status);
        _loadMeetings(); // Refresh list
      } catch (e) {
        print('Error updating meeting status to Rejected: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error rejecting meeting: $e')),
        );
      }
    }
  }

  void _showEnterUrlDialog(String meetingId, String status) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController meetingUrlController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Meeting URL'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: meetingUrlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/meet',
                labelText: 'Meeting URL',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Meeting URL cannot be empty.';
                }
                if (!_isValidUrl(value)) {
                  return 'Please enter a valid URL.';
                }
                return null;
              },
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
              child: const Text('Next'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(); // Close URL dialog
                  _showDateTimeDialog(
                      meetingId, status, meetingUrlController.text);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDateTimeDialog(
      String meetingId, String status, String meetingUrl) async {
    // Fetch the current meeting details to pre-fill date/time
    Appointment? currentMeeting;
    try {
      // Assuming FirestoreService has a method to get a single appointment
      // If not, you might need to find it in the _meetings list or fetch it
      currentMeeting = _meetings.firstWhere((m) => m.id == meetingId);
    } catch (e) {
      print("Could not find current meeting details: $e");
      // Handle error - maybe show a default date/time or prevent proceeding
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load current meeting time.')),
      );
      return;
    }

    DateTime selectedDate =
        DateFormat('yyyy-MM-dd').parse(currentMeeting.date!);
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(currentMeeting.time!.split(':')[0]),
      minute: int.parse(currentMeeting.time!.split(':')[1]),
    );

    // Use a StatefulWidget for the dialog content to manage state
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          // Use StatefulBuilder to update dialog content
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Update Meeting Time (Optional)'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text(
                        "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null && pickedDate != selectedDate) {
                        setDialogState(() {
                          // Update the dialog's state
                          selectedDate = pickedDate;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text("Time: ${selectedTime.format(context)}"),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                      );
                      if (pickedTime != null && pickedTime != selectedTime) {
                        setDialogState(() {
                          // Update the dialog's state
                          selectedTime = pickedTime;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  // Changed from "Update" to "Accept" as this is the final step
                  child: const Text('Accept'),
                  onPressed: () async {
                    final String formattedDate =
                        DateFormat('yyyy-MM-dd').format(selectedDate);
                    // Ensure time is formatted with leading zeros (HH:mm)
                    final String formattedTime =
                        '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';

                    try {
                      // We need a method in FirestoreService to update date, time, status, and URL
                      await _firestoreService.updateMeetingDetails(meetingId,
                          status, meetingUrl, formattedDate, formattedTime);
                      _loadMeetings(); // Refresh meetings list
                      Navigator.of(context).pop(); // Close the date/time dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Meeting Accepted!')),
                      );
                    } catch (e) {
                      print('Error updating meeting details: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error accepting meeting: $e')),
                      );
                      // Optionally keep the dialog open on error
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
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
