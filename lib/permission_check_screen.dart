// lib/permission_check_screen.dart

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io'; // Needed to check which platform we're on (Android/iOS)

import 'home_page.dart'; // Your existing home page

class PermissionCheckScreen extends StatefulWidget {
  @override
  _PermissionCheckScreenState createState() => _PermissionCheckScreenState();
}

class _PermissionCheckScreenState extends State<PermissionCheckScreen> {

  // This method is called exactly once when the screen is first created.
  // It's the perfect place to start our permission check.
  @override
  void initState() {
    super.initState();
    _checkAndRequestPermissions();
  }

  // This is the core logic for handling permissions.
  Future<void> _checkAndRequestPermissions() async {
    // For BLE to work on modern Android, you need several permissions.
    // We will request them all at once.
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      // On Android, location is also required to scan for BLE devices.
      Permission.locationWhenInUse,
    ].request();

    // After the user responds to the permission pop-ups, we check the results.
    // For this app, we need all the Bluetooth permissions to be granted.
    if (statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.bluetoothAdvertise]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted) {

      // --- SUCCESS ---
      // If permissions are granted, we replace this loading screen
      // with the real HomePage of the app.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage()),
      );

    } else {
      // --- FAILURE ---
      // If the user denies permission, the app cannot work.
      // Here, you should show a dialog explaining why the permissions
      // are needed and ask the user to enable them in the settings.
      print("Permissions were denied. The app cannot function.");
      // For the hackathon, you could show a simple message and close the app.
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Permissions Required"),
            content: Text("This app requires Bluetooth and Location permissions to function. Please grant them in the app settings."),
            actions: [
              TextButton(onPressed: () => exit(0), child: Text("Exit App"))
            ],
          )
      );
    }
  }

  // While we are waiting for the user to respond to the permission pop-ups,
  // we just show a simple loading circle.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}