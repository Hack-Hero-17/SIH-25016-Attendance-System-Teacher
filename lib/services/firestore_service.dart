// lib/services/firestore_service.dart (TEACHER APP)
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/class_model.dart';
import 'dart:async';
import '../models/student_attendance_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Collection Names (Defined Once) ---
  final String _classesCollection = 'classes';
  final String _slotsCollection = 'attendance_slots';
  final String _recordsCollection = 'attendance_records';
  final String _logsCollection = 'attendance_logs';

  // =======================================================
  // Methods for Managing Classes
  // =======================================================

  Stream<List<ClassModel>> getTeacherClasses(String teacherId) {
    return _db
        .collection(_classesCollection)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) => ClassModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addClass(Map<String, dynamic> classData) async {
    try {
      await _db.collection(_classesCollection).add(classData);
    } catch (e) {
      print('Error adding class: $e');
    }
  }

  // =======================================================
  // Methods for Managing Attendance Slots (for Calendars)
  // =======================================================

  Future<void> createAttendanceSlot(Map<String, dynamic> slotData) async {
    try {
      await _db.collection(_slotsCollection).add(slotData);
    } catch (e) {
      print("Error creating slot: $e");
    }
  }

  Stream<QuerySnapshot> getSlotsForTeacher(String teacherId) {
    return _db
        .collection(_slotsCollection)
        .where('teacherId', isEqualTo: teacherId)
        .snapshots();
  }

  Stream<QuerySnapshot> getSlotsForSubject(String classId) {
    return _db
        .collection(_slotsCollection)
        .where('classId', isEqualTo: classId)
        .snapshots();
  }

  // =======================================================
  // Methods for Live Attendance Viewing
  // =======================================================

  /// Streams a real-time list of student attendance for a live session.
  Stream<List<StudentAttendanceModel>> getAttendanceForSession(
      String sessionId) {
    print(
        "Querying attendance_records where sessionId=$sessionId, orderBy timestamp ascending");
    return _db
        .collection(_recordsCollection)
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snapshot) =>
        snapshot.docs
            .map((doc) => StudentAttendanceModel.fromMap(doc.data()))
            .toList());
  }


  // lib/services/firestore_service.dart

  /// Get the currently active session ID for a class
  Future<String?> getOpenSessionIdForClass(String classId) async {
    try {
      final query = await _db
          .collection('attendance_slots')
          .where('classId', isEqualTo: classId)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return query.docs.first.id; // Firestore doc ID is sessionId
      } else {
        return null; // No active session
      }
    } catch (e) {
      print("Error fetching open session for class $classId: $e");
      return null;
    }
  }

  /// Start syncing attendance logs for a session
  Future<void> startAttendanceLogSync(String sessionId, {
    required String classId,
    required String subjectName,
    required String teacherId,
  }) async {
    try {
      final sessionRef =
      _db.collection('attendance_logs').doc(sessionId);

      // Create document if it doesn't exist
      final doc = await sessionRef.get();
      if (!doc.exists) {
        await sessionRef.set({
          'sessionId': sessionId,
          'classId': classId,
          'subjectName': subjectName,
          'teacherId': teacherId,
          'students': [], // Will store attendance records
          'startedAt': FieldValue.serverTimestamp(),
        });
        print("Attendance log initialized for session: $sessionId");
      }
    } catch (e) {
      print("Error starting attendance log sync for $sessionId: $e");
    }
  }

  /// Stop syncing attendance logs
  Future<void> stopAttendanceLogSync(String sessionId) async {
    try {
      final sessionRef =
      _db.collection('attendance_logs').doc(sessionId);

      // Optionally mark as ended if needed
      final doc = await sessionRef.get();
      if (doc.exists) {
        await sessionRef.update({
          'endedAt': FieldValue.serverTimestamp(),
        });
        print("Attendance log sync stopped for session: $sessionId");
      } else {
        print("Attendance log not found for session: $sessionId");
      }
    } catch (e) {
      print("Error stopping attendance log sync for $sessionId: $e");
    }
  }

  /// Finalize an attendance slot safely
  Future<void> finalizeAttendanceSlot(String sessionId) async {
    try {
      final slotRef =
      FirebaseFirestore.instance.collection('attendance_slots').doc(sessionId);

      // Check if the session exists
      final doc = await slotRef.get();
      if (!doc.exists) {
        print("Warning: Attempted to finalize non-existent session: $sessionId");
        return;
      }

      // Update session as ended
      await slotRef.update({
        'isActive': false,
        'endedAt': Timestamp.now(),
      });

      print("Attendance session finalized successfully: $sessionId");
    } catch (e) {
      print("Error finalizing attendance session $sessionId: $e");
    }
  }

/// Get the currently active session ID for a class

/// Fetches the list of students for a session ONCE (used for creating the final log).
// Future<List<Map<String, dynamic>>> getStudentsForSessionOnce(String sessionId) async {
//   final snapshot = await _db
//       .collection(_recordsCollection)
//       .where('sessionId', isEqualTo: sessionId)
//       .get();
//
//   return snapshot.docs.map((doc) => doc.data()).toList();
// }
//
// // =======================================================
// // Methods for Historical Attendance Logs
// // =======================================================
//
// /// Creates a permanent attendance log after a session is stopped.
// Future<void> createAttendanceLog(String sessionId, Map<String, dynamic> logData) async {
//   try {
//     await _db.collection(_logsCollection).doc(sessionId).set(logData);
//   } catch (e) {
//     print("Error creating attendance log: $e");
//   }
// }
//
// /// Fetches a single, historical attendance log for viewing.
// Stream<DocumentSnapshot> getAttendanceLog(String sessionId) {
//   return _db.collection(_logsCollection).doc(sessionId).snapshots();
// }


// -------------------------
// NEW: live attendance-log sync helpers
// -------------------------
}