// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';
import 'attendance_list_screen.dart';

class CalendarScreen extends StatefulWidget {
  final String teacherId;
  const CalendarScreen({Key? key, required this.teacherId}) : super(key: key);

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  late final Stream<QuerySnapshot> _slotsStream;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> _eventsByDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _slotsStream = _firestoreService.getSlotsForTeacher(widget.teacherId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Attendance Calendar')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _slotsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          // Process the data for the calendar events
          _eventsByDay = {};
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data['date'] as Timestamp).toDate();
            final dayKey = DateFormat('yyyy-MM-dd').format(date);

            if (_eventsByDay[dayKey] == null) {
              _eventsByDay[dayKey] = [];
            }
            _eventsByDay[dayKey]!.add({
              'subjectName': data['subjectName'],
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
              Expanded(
                child: ListView.builder(
                  itemCount: eventsForSelectedDay.length,
                  itemBuilder: (context, index) {
                    final event = eventsForSelectedDay[index];
                    return ListTile(
                      title: Text('${event['subjectName']}'),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => AttendanceListScreen(
                            sessionId: event['sessionId'],
                            subjectName: event['subjectName'],
                          ),
                        ));
                      },
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