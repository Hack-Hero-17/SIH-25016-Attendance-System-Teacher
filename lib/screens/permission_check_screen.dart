// lib/screens/permission_check_screen.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'home_screen.dart';

class PermissionCheckScreen extends StatefulWidget {
  // 1. Add this to receive the user ID from LoginScreen
  final String userId;

  // 2. Update the constructor
  const PermissionCheckScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _PermissionCheckScreenState createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  Future<void> _checkAndRequestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    if (statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothAdvertise]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted) {

      // 3. Pass the userId to the HomeScreen
      // Use widget.userId to access the variable from the StatefulWidget
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(teacherId: widget.userId)),
      );

    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Permissions Required"),
            content: Text(
                "This app requires Bluetooth and Location permissions to function. Please grant them in the app settings."),
            actions: [
              TextButton(onPressed: () => exit(0), child: Text("Exit App"))
            ],
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}