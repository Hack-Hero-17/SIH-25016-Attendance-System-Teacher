// lib/screens/class_details_screen.dart
import 'package:flutter/material.dart';
import '../models/class_model.dart';
import 'attendance_broadcast_screen.dart';

class ClassDetailsScreen extends StatelessWidget {
final ClassModel classModel;

const ClassDetailsScreen({Key? key, required this.classModel}) : super(key: key);

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text(classModel.subjectName),
),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text('Subject Code: ${classModel.subjectCode}'),
Text('Program: ${classModel.program}'),
Text('Semester: ${classModel.semester}'),
SizedBox(height: 30),
    Center(
      child: ElevatedButton(
        onPressed: () {
          // Navigate to AttendanceBroadcastScreen with "forceNewSession = true"
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AttendanceBroadcastScreen(
                classModel: classModel,
                forceNewSession: true, // 🔹 Pass this flag
              ),
            ),
          );
        },
        child: Text('Create New Attendance Slot'),
      ),
    )
    ],
  ),
),
);
}
}

