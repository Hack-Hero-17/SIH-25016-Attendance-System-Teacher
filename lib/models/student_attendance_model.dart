// lib/models/student_attendance_model.dart (TEACHER APP)
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentAttendanceModel {
  final String studentName;
  final String studentRegNo;
  final DateTime timestamp;

  StudentAttendanceModel({
    required this.studentName,
    required this.studentRegNo,
    required this.timestamp,
  });

  factory StudentAttendanceModel.fromMap(Map<String, dynamic> data) {
    return StudentAttendanceModel(
      studentName: data['studentName'] ?? 'Unknown Student',
      studentRegNo: data['studentRegNo'] ?? 'N/A',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}