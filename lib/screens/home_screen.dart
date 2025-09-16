// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/class_model.dart';
import 'class_details_screen.dart';//-- IMPORT THE NEW SCREEN
import '../widgets/custom_card.dart';
import 'create_class_screen.dart';

import 'calendar_screen.dart'; // Import new screen
import 'subjects_list_screen.dart'; // Import new screen// <-- 1. IMPORT THE NEW SCREEN


class HomeScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  // 1. Add this final variable to hold the teacher's ID
  final String teacherId;

  // 2. Update the constructor to require the teacherId
  HomeScreen({Key? key, required this.teacherId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 3. The hardcoded line is now gone.
    // The `teacherId` variable from the constructor will be used directly.

    return Scaffold(
      // --- START OF NEW/MODIFIED CODE ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: const Text('View Calendar'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CalendarScreen(teacherId: teacherId),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: const Text('My Subjects'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SubjectsListScreen(teacherId: teacherId),
                ));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('My Classes'),
      ),
      // The rest of the widget uses the 'teacherId' variable, so it works perfectly.
      body: StreamBuilder<List<ClassModel>>(
        stream: _firestoreService.getTeacherClasses(teacherId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No classes found.'));
          }

          var classes = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(8),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              var course = classes[index];
              return CustomCard(
                title: course.subjectName,
                subtitle: '${course.program} - Sem ${course.semester}',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ClassDetailsScreen(classModel: course),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the CreateClassScreen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateClassScreen(teacherId: teacherId),
            ),
          );
        },
        child: Icon(Icons.add),
        tooltip: 'Add Class', // Good practice to add a tooltip
      ),
    );
  }
}