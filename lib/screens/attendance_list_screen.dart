import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/student_attendance_model.dart';

class AttendanceListScreen extends StatelessWidget {
  final String sessionId;
  final String subjectName;

  AttendanceListScreen({
    Key? key,
    required this.sessionId,
    required this.subjectName,
  }) : super(key: key);

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(subjectName),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Live Student List',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _db
            .collection('attendance_records')
            .where('sessionId', isEqualTo: sessionId)
            .snapshots(), // 🔹 live updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No students have marked attendance yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // 🔹 Map Firestore docs to StudentAttendanceModel
          final students = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return StudentAttendanceModel(
              studentName: data['studentName'] ?? '',
              studentRegNo: data['studentRegNo'] ?? '',
              timestamp: (data['timestamp'] as Timestamp).toDate(),
            );
          }).toList();

          // 🔹 Local sort by timestamp
          students.sort((a, b) => a.timestamp.compareTo(b.timestamp));

          return Column(
            children: [
              // Summary card
              Card(
                margin: EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        "Attendance Summary",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Total Students Present: ${students.length}",
                        style: TextStyle(fontSize: 16, color: Colors.green),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Session ID: $sessionId",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              // Student list
              Expanded(
                child: ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(student.studentName,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(student.studentRegNo),
                        trailing: Text(DateFormat('HH:mm:ss')
                            .format(student.timestamp)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}