// lib/models/class_model.dart
class ClassModel {
  final String id;
  final String subjectName;
  final String subjectCode;
  final String program;
  final int semester;
  final String teacherId;

  ClassModel({
    required this.id,
    required this.subjectName,
    required this.subjectCode,
    required this.program,
    required this.semester,
    required this.teacherId,
  });

  factory ClassModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ClassModel(
      id: documentId,
      subjectName: data['subjectName'],
      subjectCode: data['subjectCode'],
      program: data['program'],
      semester: data['semester'],
      teacherId: data['teacherId'],
    );
  }
}