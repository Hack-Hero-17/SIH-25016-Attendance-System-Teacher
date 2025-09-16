// lib/screens/subjects_list_screen.dart
import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../services/firestore_service.dart';
import 'subject_calendar_screen.dart'; // Import the next screen
import '../widgets/custom_card.dart';

class SubjectsListScreen extends StatelessWidget {
  final String teacherId;
  final FirestoreService _firestoreService = FirestoreService();

  SubjectsListScreen({Key? key, required this.teacherId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Subjects')),
      body: StreamBuilder<List<ClassModel>>(
        stream: _firestoreService.getTeacherClasses(teacherId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final classes = snapshot.data!;
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final course = classes[index];
              return CustomCard(
                title: course.subjectName,
                subtitle: course.subjectCode,
                onTap: () {
                  // Navigate to the specific calendar for this subject
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SubjectCalendarScreen(classModel: course),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}