// lib/screens/attendance_broadcast_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';
import '../services/firestore_service.dart';
import 'attendance_list_screen.dart';

class AttendanceBroadcastScreen extends StatefulWidget {
  final ClassModel classModel;
  final bool forceNewSession;

  const AttendanceBroadcastScreen({Key? key, required this.classModel,
    this.forceNewSession = false,
  })
      : super(key: key);

  @override
  _AttendanceBroadcastScreenState createState() =>
      _AttendanceBroadcastScreenState();
}

class _AttendanceBroadcastScreenState extends State<AttendanceBroadcastScreen> {
  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();
  final FirestoreService _firestoreService = FirestoreService();

  String _sessionId = '';
  bool _isBroadcasting = false;
  bool _isLoading = false; // Loading indicator

  @override
  void initState() {
    super.initState();
    _initActiveSession(); // Check if there’s an active session on start
  }

  /// Initialize existing active session if any
  Future<void> _initActiveSession() async {
    setState(() => _isLoading = true);
    try {
      final activeSessionId =
      await _firestoreService.getOpenSessionIdForClass(widget.classModel.id);
      if (activeSessionId != null) {
        _sessionId = activeSessionId;
        _isBroadcasting = true;
      }
    } catch (e) {
      print("Error fetching active session: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Start or resume a session safely
  Future<void> _startOrResumeSession() async {
    setState(() => _isLoading = true);

    try {
      String? existingSessionId;

      if (!widget.forceNewSession) {
        // Only check for open session if not forcing new
        existingSessionId =
        await _firestoreService.getOpenSessionIdForClass(widget.classModel.id);
      }

      if (existingSessionId != null) {
        // Resume existing session
        _sessionId = existingSessionId;
        print("Resuming existing session: $_sessionId");
      } else {
        // Create new session in Firestore
        _sessionId = Uuid().v4();
        final slotData = {
          'sessionId': _sessionId,
          'classId': widget.classModel.id,
          'subjectName': widget.classModel.subjectName,
          'teacherId': widget.classModel.teacherId,
          'date': Timestamp.now(),
          'isActive': true,
          'endedAt': null,
        };
        await FirebaseFirestore.instance
            .collection('attendance_slots')
            .doc(_sessionId)
            .set(slotData);
        print("New attendance slot created: $_sessionId");
      }

      // Start BLE advertising
      final advertiseData = AdvertiseData(
        serviceUuid: 'bf2774e1-3248-4467-9c48-3b36cec554c0',
        manufacturerId: 1234,
        manufacturerData: utf8.encode(_sessionId),
      );
      await _blePeripheral.start(advertiseData: advertiseData);

      if (await _blePeripheral.isAdvertising && mounted) {
        setState(() => _isBroadcasting = true);
        _firestoreService.startAttendanceLogSync(
          _sessionId,
          classId: widget.classModel.id,
          subjectName: widget.classModel.subjectName,
          teacherId: widget.classModel.teacherId,
        );
      }
    } catch (e) {
      print("Error starting/resuming session: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }



  /// Stop broadcasting safely
  Future<void> _stopBroadcast({bool finalize = false}) async {
    setState(() => _isLoading = true);
    try {
      await _blePeripheral.stop();
      await Future.delayed(const Duration(milliseconds: 500));

      if (finalize) {
        await _firestoreService.finalizeAttendanceSlot(_sessionId);
        print("Session finalized: $_sessionId");
      } else {
        print("Broadcast paused, session kept active: $_sessionId");
      }

      await _firestoreService.stopAttendanceLogSync(_sessionId);

      if (mounted) setState(() => _isBroadcasting = false);
    } catch (e) {
      print("Error stopping broadcast: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }


  /// Toggle broadcast (start/resume or stop)
  Future<void> _toggleBroadcast() async {
    if (_isBroadcasting) {
      await _stopBroadcast();
    } else {
      await _startOrResumeSession();
    }
  }

  @override
  void dispose() {
    if (_isBroadcasting) _blePeripheral.stop();
    _firestoreService.stopAttendanceLogSync(_sessionId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast Attendance')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Processing...", style: TextStyle(fontSize: 16)),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Class:', style: Theme.of(context).textTheme.titleMedium),
              Text(
                widget.classModel.subjectName,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Live attendance display
              if (_isBroadcasting)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('attendance_records')
                      .where('sessionId', isEqualTo: _sessionId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No attendance yet");
                    }

                    final students = snapshot.data!.docs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['studentName'] ?? '';
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Total Students: ${students.length}"),
                        const SizedBox(height: 8),
                        ...students.map((s) => Text("✔️ $s")),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          icon: const Icon(Icons.people_alt_outlined),
                          label: const Text('View Details'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AttendanceListScreen(
                                  sessionId: _sessionId,
                                  subjectName: widget.classModel.subjectName,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),

              if (!_isBroadcasting)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80.0),
                  child: Text(
                    "Press 'Start Advertising' to begin.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),

              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: _isBroadcasting ? Colors.red : Colors.green,
                ),
                child: Text(
                  _isBroadcasting ? 'Stop Advertising' : 'Start Advertising',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                onPressed: _toggleBroadcast,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
