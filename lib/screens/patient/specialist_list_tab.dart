import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/appoitment.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_model.dart';
import 'meetings_tab.dart';

class SpecialistListTab extends StatefulWidget {
  const SpecialistListTab({Key? key}) : super(key: key);

  @override
  State<SpecialistListTab> createState() => _SpecialistListTabState();
}

class _SpecialistListTabState extends State<SpecialistListTab> {
  final FirestoreService _firestoreService = FirestoreService();
  List<AppUser> _specialists = [];

  @override
  void initState() {
    super.initState();
    _loadSpecialists();
  }

  _loadSpecialists() async {
    // Assuming you have a way to differentiate specialists from other users in Firestore, e.g., by role
    List<AppUser> specialists =
        await _firestoreService.getUsersByRole('specialist');
    setState(() {
      _specialists = specialists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consult Specialists'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MeetingsTab();
                }));
              },
              child: Icon(Icons.history),
            ),
          )
        ],
      ),
      body: _specialists.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _specialists.length,
              itemBuilder: (context, index) {
                final specialist = _specialists[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          specialist.name ?? 'N/A',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Specialty: ${specialist.specialty ?? 'N/A'}'),
                        Text(
                            'Availability: ${specialist.availability?.join(', ') ?? 'N/A'}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _showBookingDialog(context, specialist);
                          },
                          child: const Text('Book Appointment'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showBookingDialog(BuildContext context, AppUser specialist) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Book Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Book appointment with ${specialist.name}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2026),
                  );
                  if (selectedDate != null) {
                    // ignore: use_build_context_synchronously
                    TimeOfDay? selectedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (selectedTime != null) {
                      // Combine date and time
                      DateTime combinedDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.hour,
                        selectedTime.minute,
                      );

                      // Get current user ID
                      String? patientId =
                          FirebaseAuth.instance.currentUser?.uid;
                      if (patientId != null) {
                        // Generate UUID for meeting ID
                        String meetingId = const Uuid().v4();

                        // Create Appointment object
                        Appointment appointment = Appointment(
                          id: meetingId, // Assign generated UUID
                          patientId: patientId,
                          specialistId: specialist.uid,
                          date: combinedDateTime.toString(),
                          time: selectedTime.format(context),
                          status: 'Pending', // Default status
                        );

                        // Add meeting to Firestore
                        final success = await _firestoreService.addMeeting(
                            appointment, context);

                        // Show confirmation dialog
                        // ignore: use_build_context_synchronously
                        if (success) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Appointment Booked'),
                                content: const Text(
                                    'Your appointment has been booked successfully.'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context)
                                          .pop(); // Close booking dialog
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    }
                  }
                },
                child: const Text('Pick Date and Time'),
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
            TextButton(
              child: const Text('Book'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
