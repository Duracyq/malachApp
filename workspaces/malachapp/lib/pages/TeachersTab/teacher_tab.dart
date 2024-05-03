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
  Future<bool> _checkTodaysAvaibility() async {
    try {
      final DateTime now = DateTime.now();
      final String day = now.weekday == 1 ? 'Monday' : now.weekday == 2 ? 'Tuesday' : now.weekday == 3 ? 'Wednesday' : now.weekday == 4 ? 'Thursday' : now.weekday == 5 ? 'Friday' : '';
      final String hour = now.hour.toString();
      final String minute = now.minute.toString();
      final String time = '$hour:$minute';
      final String teacherId = widget.teacherId;
      final DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('teachersList').doc(teacherId).get();
      
      if (snapshot.exists) {
        return snapshot['workHours'][day]['start'] <= time && snapshot['workHours'][day]['end'] >= time;
      } else {
        return false; // Assuming false if document doesn't exist
      }
    } catch (error) {
      print('Error fetching availability: $error');
      return false; // Return false in case of error
    }
  }


  String _showTodaysAvaibility() {
    final DateTime now = DateTime.now();
    final String day = now.weekday == 1 ? 'Monday' : now.weekday == 2 ? 'Tuesday' : now.weekday == 3 ? 'Wednesday' : now.weekday == 4 ? 'Thursday' : now.weekday == 5 ? 'Friday' : '';
    final String hour = now.hour.toString();
    final String minute = now.minute.toString();
    final String time = '$hour:$minute';
    final String today = '$day $time';
    final String teacherId = widget.teacherId;
    final FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection('teachersList').doc(teacherId).get().then((value) {
      if (value.exists) {
        if (value['workHours'][day]['start'] <= time && value['workHours'][day]['end'] >= time) {
          return 'Od: ${value['workHours'][day]['start']} do: ${value['workHours'][day]['end']}';
        } else {
          return 'Nie pracuje dzisiaj';
        }
      } else {
        return 'Brak Danych';
      }
    }).catchError((error) {
      print("Error: $error");
      return 'Brak Danych';
    });
    return 'Brak Danych';
  }


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
          
          FutureBuilder<bool>(
            future: _checkTodaysAvaibility(),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text('Dostępność dzisiaj'),
                  subtitle: Text('Ładowanie...'),
                );
              } else {
                if (futureSnapshot.hasError) {
                  return const ListTile(
                    title: Text('Dostępność dzisiaj'),
                    subtitle: Text('Wystąpił błąd podczas pobierania danych.'),
                  );
                } else {
                  return ListTile(
                    title: const Text('Dostępność dzisiaj'),
                    subtitle: Text(futureSnapshot.data == true ? _showTodaysAvaibility() : 'Nie pracuje obecnie.'),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Dostępność dzisiaj'),
                              content: Text('Od: ${widget.teacherSnapshot['workHours']['Friday']['start']} do: ${widget.teacherSnapshot['workHours']['Monday']['end']}'),
                            );
                          },
                        );
                    },
                  );
                }
              }
            },
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