import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malachapp/auth/auth_service.dart';
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
          FutureBuilder(
            future: AuthService().isAdmin(),
            builder: (context, futureSnapshot) {
              return Visibility(
                visible: futureSnapshot.hasData && futureSnapshot.data == true || widget.teacherSnapshot['accountMail'] == FirebaseAuth.instance.currentUser!.email,
                child: ListTile(
                  title: const Text('Ustaw godziny pracy'),
                  subtitle: Text('DEBUG: isAdmin: ${futureSnapshot.data} | teacherMail: ${(widget.teacherSnapshot['accountMail'] == FirebaseAuth.instance.currentUser!.email)}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => WorkHoursCreator(teacherId: widget.teacherId,),
                      ),
                    );
                  },
                ),
              );
            }
          )
        ],
      ),
    );
  }
}