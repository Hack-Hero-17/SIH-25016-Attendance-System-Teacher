import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:uuid/uuid.dart';

class TeacherScreen extends StatefulWidget {
  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();
  String _sessionId = '';
  bool _isBroadcasting = false;

  void _generateSessionId() {
    setState(() {
      _sessionId = Uuid().v4();
    });
  }

  Future<void> _toggleBroadcast() async {
    if (await _blePeripheral.isAdvertising) {
      await _blePeripheral.stop();
      setState(() {
        _isBroadcasting = false;
      });
    } else {
      if (_sessionId.isEmpty) {
        _generateSessionId();
      }

      AdvertiseData advertiseData = AdvertiseData(
        serviceUuid: 'bf2774e1-3248-4467-9c48-3b36cec554c0', // A unique UUID for your service
        manufacturerId: 1234,
        manufacturerData: utf8.encode(_sessionId),
      );

      // --- FIX IS HERE ---
      // Set the data before starting
      await _blePeripheral.start(advertiseData: advertiseData);
      // Now check if it's advertising
      if (await _blePeripheral.isAdvertising) {
        setState(() {
          _isBroadcasting = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _generateSessionId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Session ID:',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              _sessionId,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              child: Text(_isBroadcasting ? 'Stop Advertising' : 'Start Advertising'),
              onPressed: _toggleBroadcast,
            ),
          ],
        ),
      ),
    );
  }
}