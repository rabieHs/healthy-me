import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/appoitment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingsTab extends StatefulWidget {
  const MeetingsTab({Key? key}) : super(key: key);

  @override
  State<MeetingsTab> createState() => _MeetingsTabState();
}

class _MeetingsTabState extends State<MeetingsTab> {
  final FirestoreService _firestoreService = FirestoreService();
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
          await _firestoreService.getPatientMeetings(user.uid);
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
              return GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Meeting resume"),
                          content:
                              Text(meeting.resume ?? 'No resume available.'),
                        );
                      });
                },
                child: Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        FutureBuilder<AppUser?>(
                          future:
                              _firestoreService.getUser(meeting.specialistId!),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (!snapshot.hasData || snapshot.data == null) {
                              return const Text('Specialist Name: N/A');
                            }
                            final specialist = snapshot.data!;
                            return Text(
                              'Meeting with Dr. ${specialist.name ?? 'N/A'}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Text('Date: ${meeting.date}'),
                        Text('Time: ${meeting.time}'),
                        Text('Status: ${meeting.status}'),
                        const SizedBox(height: 8),
                        meeting.meetingUrl != null &&
                                meeting.meetingUrl!.isNotEmpty
                            ? GestureDetector(
                                onTap: () async {
                                  print("Meeting link: ${meeting.meetingUrl}");
                                  if (meeting.meetingUrl != null) {
                                    Uri url = Uri.parse(meeting.meetingUrl!);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url);
                                    } else {
                                      throw 'Could not launch ${meeting.meetingUrl}';
                                    }
                                  }
                                },
                                child: Text(
                                  'Meeting Link',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }
}
