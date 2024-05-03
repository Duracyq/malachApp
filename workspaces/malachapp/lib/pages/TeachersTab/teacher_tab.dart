import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malachapp/pages/TeachersTab/workhours_selector.dart';

class TeacherTab extends StatefulWidget {
  final DocumentSnapshot teacherSnapshot;
  final String teacherId;

  TeacherTab({required this.teacherSnapshot, required this.teacherId});

  @override
  State<TeacherTab> createState() => _TeacherTabState();
}

class _TeacherTabState extends State<TeacherTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Tab'),
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
            title: const Text('work hours creator'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WorkHoursCreator(teacherId: widget.teacherId,),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}