import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherTab extends StatefulWidget {
  final DocumentSnapshot teacherSnapshot;

  TeacherTab({required this.teacherSnapshot});

  @override
  State<TeacherTab> createState() => _TeacherTabState();
}

class _TeacherTabState extends State<TeacherTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Tab'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('${widget.teacherSnapshot['name']} ${widget.teacherSnapshot['surname']}'),
          ),
          ListTile(
            title: Text('Subject: ${widget.teacherSnapshot['subject'].join(', ')}'),
          ),
          ListTile(
            title: Text('Email: ${widget.teacherSnapshot['accountMail']}'),
          ),
          ListTile(
            // title: Text('Avaiblability: ${widget.teacherSnapshot['workHours'] ?? 'Brak danych'}'),
          )
        ],
      ),
    );
  }
}