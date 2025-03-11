import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/firestore_service.dart';
import '../../models/appoitment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class PatientsTab extends StatefulWidget {
  const PatientsTab({super.key});

  @override
  State<PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<PatientsTab> {
  final FirestoreService firestoreService = FirestoreService();
  String? specialistId;

  @override
  void initState() {
    super.initState();
    specialistId = FirebaseAuth.instance.currentUser?.uid;
    if (specialistId != null) {
      // Fetch meetings and patients data when the widget is initialized
      _fetchMeetingsAndPatients();
    }
  }

  Future<void> _fetchMeetingsAndPatients() async {
    if (specialistId == null) {
      return;
    }
    List<Appointment> meetings =
        await firestoreService.getSpecialistMeetings(specialistId!);
    // Filter out meetings with null patientId and map to Set<String>
    Set<String> patientIds = meetings
        .where((meeting) => meeting.patientId != null)
        .map((meeting) => meeting.patientId!)
        .toSet();

    List<AppUser> patients = [];
    for (String patientId in patientIds) {
      AppUser? patient = await firestoreService.getUser(patientId);
      if (patient != null) {
        patients.add(patient);
      }
    }
    setState(() {
      _patients = patients;
      _originalPAtients = patients;
      _meetings = meetings;
    });
  }

  List<AppUser> _patients = [];
  List<AppUser> _originalPAtients = [];
  List<Appointment> _meetings = [];
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "search"),
              onChanged: (value) {
                print(value);
                setState(() {
                  if (value.isNotEmpty) {
                    _patients = _originalPAtients
                        .where((patient) => patient.name!.startsWith(value))
                        .toList();
                  } else {
                    _patients = _originalPAtients;
                  }
                });
              },
            ),
            SizedBox(
              height: 15,
            ),
            _patients.isEmpty
                ? const Center(child: Text('No patients found.'))
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _patients.length,
                    itemBuilder: (context, index) {
                      final patient = _patients[index];
                      if (patient == null) {
                        return const ListTile(
                          title: Text('Error: Patient data is null'),
                        );
                      }
                      return Card(
                        elevation: 4.0,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Container(
                          decoration: const BoxDecoration(
                              color: Color.fromRGBO(64, 75, 96, .9)),
                          child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 10.0),
                              leading: Container(
                                padding: const EdgeInsets.only(right: 12.0),
                                decoration: const BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            width: 1.0,
                                            color: Colors.white24))),
                                child: const Icon(Icons.person,
                                    color: Colors.white),
                              ),
                              title: Text(
                                patient.name!,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              subtitle: Text(patient.email ?? '',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 16)),
                              trailing: const Icon(Icons.arrow_forward,
                                  color: Colors.white),
                              onTap: () {
                                // Navigate to patient details page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PatientDetailsPage(
                                        patient: patient, meetings: _meetings),
                                  ),
                                );
                              }),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

class PatientDetailsPage extends StatelessWidget {
  final AppUser? patient;
  final List<Appointment> meetings;

  const PatientDetailsPage(
      {super.key, required this.patient, required this.meetings});

  @override
  Widget build(BuildContext context) {
    // Filter meetings for the selected patient
    List<Appointment> patientMeetings =
        meetings.where((m) => m.patientId == patient!.uid).toList();

    if (patient == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Patient Details Error'),
        ),
        body: Center(
          child: Text('Patient data is null.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(patient!.name!),
      ),
      body: patientMeetings.isEmpty
          ? const Center(child: Text('No meetings found for this patient.'))
          : ListView.builder(
              itemCount: patientMeetings.length,
              itemBuilder: (context, index) {
                final meeting = patientMeetings[index];
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 6.0),
                  child: Container(
                    decoration: const BoxDecoration(
                        color: Color.fromRGBO(64, 75, 96, .9)),
                    child: ExpansionTile(
                      leading: Container(
                        padding: const EdgeInsets.only(right: 12.0),
                        decoration: const BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                    width: 1.0, color: Colors.white24))),
                        child: const Icon(Icons.calendar_today,
                            color: Colors.white),
                      ),
                      title: Text(
                        'Meeting on ${meeting.date ?? "N/A"}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      subtitle: Text('Status: ${meeting.status ?? "N/A"}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 16)),
                      trailing:
                          const Icon(Icons.expand_more, color: Colors.white),
                      childrenPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      children: <Widget>[
                        const SizedBox(height: 10),
                        ListTile(
                          leading:
                              const Icon(Icons.schedule, color: Colors.white),
                          title: Text(
                            'Time: ${meeting.time ?? "N/A"}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description,
                              color: Colors.white),
                          title: const Text(
                            'Report',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          subtitle: const Text('No report yet',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MeetingDetailsPage extends StatelessWidget {
  final Appointment? meeting;

  const MeetingDetailsPage({super.key, required this.meeting});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Date: ${meeting?.date ?? "N/A"}'),
            ),
            ListTile(
              title: Text('Time: ${meeting?.time ?? "N/A"}'),
            ),
            ListTile(
              title: Text('Status: ${meeting?.status ?? "N/A"}'),
            ),
            ExpansionTile(
              title: const Text('Report'),
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, bottom: 20.0),
                  child: Text(meeting?.report ?? 'No report yet',
                      style: const TextStyle(color: Colors.black)),
                ),
              ],
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
