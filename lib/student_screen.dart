import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  String _foundSessionId = '';
  bool _isScanning = false;
  final Guid _targetServiceUuid = Guid('bf2774e1-3248-4467-9c48-3b36cec554c0');

  void _startScan() {
    setState(() {
      _isScanning = true;
      _foundSessionId = '';
    });

    // --- FIX IS HERE: REMOVED .instance ---
    FlutterBluePlus.startScan(
        withServices: [_targetServiceUuid],
        timeout: Duration(seconds: 10)
    );

    // --- FIX IS HERE: REMOVED .instance ---
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        // The service UUID check is now done in startScan, but we can double-check
        // and extract manufacturer data here.
        if (r.advertisementData.manufacturerData.containsKey(1234)) {
          setState(() {
            _foundSessionId = utf8.decode(r.advertisementData.manufacturerData[1234]!);
          });
          // --- FIX IS HERE: REMOVED .instance ---
          FlutterBluePlus.stopScan();
          break;
        }
      }
    });

    // A listener to know when the scan is stopped
    FlutterBluePlus.isScanning.listen((isScanning) {
      if (mounted) {
        setState(() {
          _isScanning = isScanning;
        });
      }
    });
  }

  Future<void> _saveSessionId() async {
    if (_foundSessionId.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('attendance').add({
          'sessionId': _foundSessionId,
          'studentId': 'student123', // Replace with actual student ID
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session ID saved successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving Session ID: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text(_isScanning ? 'Scanning...' : 'Scan for Session ID'),
              onPressed: _isScanning ? null : _startScan,
            ),
            SizedBox(height: 40),
            Text(
              'Found Session ID:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              _foundSessionId.isNotEmpty ? _foundSessionId : 'Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              child: Text('Save Session ID to Firestore'),
              onPressed: _foundSessionId.isNotEmpty ? _saveSessionId : null,
            ),
          ],
        ),
      ),
    );
  }
}