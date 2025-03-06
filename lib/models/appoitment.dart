import 'package:uuid/uuid.dart';

class Appointment {
  String? id;
  String? patientId;
  String? specialistId;
  String? date;
  String? time;
  String? status;
  String? meetingUrl;
  String? report;

  Appointment({
    String? id,
    this.patientId,
    this.specialistId,
    this.date,
    this.time,
    this.status,
    this.meetingUrl = '',
    this.report,
  }) : id = id ?? Uuid().v4(); // Generate UUID if id is not provided

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'],
      patientId: map['patient_id'],
      specialistId: map['specialist_id'],
      date: map['date'],
      time: map['time'],
      status: map['status'],
      meetingUrl: map['meeting_url'],
      report: map['report'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patient_id': patientId,
      'specialist_id': specialistId,
      'date': date,
      'time': time,
      'status': status,
      'meeting_url': meetingUrl,
      'report': report,
    };
  }
}
