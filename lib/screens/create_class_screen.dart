// lib/screens/create_class_screen.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class CreateClassScreen extends StatefulWidget {
  final String teacherId;

  const CreateClassScreen({Key? key, required this.teacherId}) : super(key: key);

  @override
  _CreateClassScreenState createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectNameController = TextEditingController();
  final _subjectCodeController = TextEditingController();
  final _programController = TextEditingController();
  final _semesterController = TextEditingController();
  bool _isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Map<String, dynamic> classData = {
        'subjectName': _subjectNameController.text,
        'subjectCode': _subjectCodeController.text,
        'program': _programController.text,
        'semester': int.tryParse(_semesterController.text) ?? 0,
        'teacherId': widget.teacherId, // Use the passed-in teacherId
      };

      await _firestoreService.addClass(classData);

      if (mounted) {
        Navigator.of(context).pop(); // Go back to the home screen
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create New Class')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _subjectNameController,
                decoration: InputDecoration(labelText: 'Subject Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _subjectCodeController,
                decoration: InputDecoration(labelText: 'Subject Code'),
                validator: (value) => value!.isEmpty ? 'Please enter a code' : null,
              ),
              TextFormField(
                controller: _programController,
                decoration: InputDecoration(labelText: 'Program (e.g., B.Tech)'),
                validator: (value) => value!.isEmpty ? 'Please enter a program' : null,
              ),
              TextFormField(
                controller: _semesterController,
                decoration: InputDecoration(labelText: 'Semester'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Please enter a semester' : null,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _submitForm,
                child: Text('Save Class'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}