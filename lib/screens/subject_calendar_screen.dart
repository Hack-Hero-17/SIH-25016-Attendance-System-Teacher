// lib/screens/subject_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';
import '../services/firestore_service.dart';
import 'attendance_list_screen.dart';

class SubjectCalendarScreen extends StatefulWidget {
  final ClassModel classModel;
  const SubjectCalendarScreen({Key? key, required this.classModel}) : super(key: key);

  @override
  _SubjectCalendarScreenState createState() => _SubjectCalendarScreenState();
}

class _SubjectCalendarScreenState extends State<SubjectCalendarScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late final Stream<QuerySnapshot> _slotsStream;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // The query is now filtered by the class ID
    _slotsStream = _firestoreService.getSlotsForSubject(widget.classModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.classModel.subjectName)),
      body: StreamBuilder<QuerySnapshot>(
        stream: _slotsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          _eventsByDay = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            final dayKey = DateFormat('yyyy-MM-dd').format(date);

            if (_eventsByDay[dayKey] == null) {
              _eventsByDay[dayKey] = [];
            }
            _eventsByDay[dayKey]!.add({
              'sessionId': data['sessionId'],
            });
          }

          final selectedDayKey = DateFormat('yyyy-MM-dd').format(_selectedDay!);
          final eventsForSelectedDay = _eventsByDay[selectedDayKey] ?? [];

          return Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) {
                  final dayKey = DateFormat('yyyy-MM-dd').format(day);
                  return _eventsByDay[dayKey] ?? [];
                },
              ),
              const SizedBox(height: 8.0),
              // If a day with attendance is selected, show a button to view it
              if (eventsForSelectedDay.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    child: Text('View Attendance for this day'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AttendanceListScreen(
                          sessionId: eventsForSelectedDay.first['sessionId'],
                          subjectName: widget.classModel.subjectName,
                        ),
                      ));
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