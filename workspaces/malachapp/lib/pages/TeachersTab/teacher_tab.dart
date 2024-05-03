import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/pages/TeachersTab/workhours_selector.dart';

class TeacherTab extends StatefulWidget {
  final DocumentSnapshot teacherSnapshot;
  final String teacherId;

  TeacherTab({required this.teacherSnapshot, required this.teacherId});

  @override
  State<TeacherTab> createState() => _TeacherTabState();
}

class _TeacherTabState extends State<TeacherTab> {
  final Logger logger = Logger();
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

Future<bool> isPastWorkHours() async {
  try {
    final DateTime now = DateTime.now();
    final String day = _getWeekdayName(now.weekday);
    final String hour = _formatNumber(now.hour);
    final String minute = _formatNumber(now.minute);
    final String time = '$hour:$minute';
    final String teacherId = widget.teacherId;

    final DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('teachersList').doc(teacherId).get();

    if (snapshot.exists) {
      final Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('workHours')) {
        final Map<String, dynamic> workHours = data['workHours'];

        if (workHours.containsKey(day)) {
          final Map<String, dynamic>? dayWorkHours = workHours[day] as Map<String, dynamic>?;

          if (dayWorkHours != null && dayWorkHours.containsKey('start') && dayWorkHours.containsKey('end')) {
            final String startWorkHour = dayWorkHours['start'];
            final String endWorkHour = dayWorkHours['end'];

            final DateTime endDateTime = DateTime(now.year, now.month, now.day, int.parse(endWorkHour.split(':')[0]), int.parse(endWorkHour.split(':')[1]));

            // Comparing DateTime objects directly
            return endDateTime.isBefore(now);
          }
        }
      }
    }
  } catch (e) {
    print('Error occurred: $e');
    // Handle error gracefully, maybe return a default value or throw
  }

  return false; // Assuming false if document doesn't exist or work hours are not set
}




  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      default:
        return '';
    }
  }  
  
  String _getWeekdayNameTranslated(int weekday) {
    switch (weekday) {
      case 1:
        return 'Poniedziałek';
      case 2:
        return 'Wtorek';
      case 3:
        return 'Środa';
      case 4:
        return 'Czwartek';
      case 5:
        return 'Piątek';
      default:
        return '';
    }
  }

  String _formatNumber(int number) {
    return number.toString().padLeft(2, '0');
  }


  bool isWeekend = false;
  String _isWeekendDay(DateTime now, int shift) {
    final int weekday = now.weekday;
    if((weekday == DateTime.saturday || weekday == DateTime.sunday)) {
      isWeekend = true;
      return 'Monday';
    } else {
      return _fetchWeekday(now, shift);
    }
  }

  String _fetchWeekday(DateTime now, int shift) {
    final int weekday = now.weekday + shift;
    switch (weekday) {
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      default:
        return '';
    }
  }
  String _showDateShifted(int shift) {
    final DateTime now = DateTime.now().add(Duration(days: shift));
    final String day = now.weekday == 1 ? 'Monday' : now.weekday == 2 ? 'Tuesday' : now.weekday == 3 ? 'Wednesday' : now.weekday == 4 ? 'Thursday' : now.weekday == 5 ? 'Friday' : '';
    return day;
  }

  String _showTodaysAvaibility(int shift) {
    final DateTime now = DateTime.now().add(Duration(days: shift));
    final String day = _getWeekdayName(now.weekday);
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
    final FirebaseFirestore db = FirebaseFirestore.instance;
    return Scaffold(
      appBar: AppBar(
        title: Text('Nauczyciel - ${widget.teacherSnapshot['name']} ${widget.teacherSnapshot['surname']}'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('${widget.teacherSnapshot['name']} ${widget.teacherSnapshot['surname']}'),
          ),
          ListTile(
            title: Text('Przedmiot: ${widget.teacherSnapshot['subject'].join(', ')}'),
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
                    subtitle: Text(futureSnapshot.data == true ? _showTodaysAvaibility(0) : 'Nie pracuje obecnie.'),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Dostępność'),
                            content: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8, // Example width, adjust as needed
                              height: MediaQuery.of(context).size.height * 0.65, // Example height, adjust as needed
                              child: Column(
                                children: [
                                  Expanded(
                                    child: StreamBuilder(
                                      stream: FirebaseFirestore.instance.collection('teachersList').doc(widget.teacherId).snapshots(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else {
                                          if (snapshot.hasError) {
                                            return const Text('Błąd podczas pobierania danych');
                                          } else {
                                            final data = snapshot.data?.data();
                                            if (data != null) {
                                              return ListView.builder(
                                                itemCount: 5,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Text(_getWeekdayNameTranslated(index+1), style: TextStyle(
                                                      fontWeight: DateTime.now().weekday == index+1 ? FontWeight.bold : FontWeight.normal,
                                                      fontSize: DateTime.now().weekday == index+1 ? 20 : 16
                                                    ),),
                                                    subtitle: Wrap(
                                                      clipBehavior: Clip.hardEdge,
                                                      alignment: WrapAlignment.spaceAround,
                                                      spacing: 10,
                                                      children: [
                                                        Text('🕓: ${data['workHours'][_getWeekdayName(index+1)]['start']}'),
                                                        Text('🕖: ${data['workHours'][_getWeekdayName(index+1)]['end']}'),
                                                      ],
                                                    )
                                                  );
                                                }
                                              );
                                            } else {
                                              return const Text('Brak dostępnych danych');
                                            }
                                          }
                                        }
                                      }
                                    ),
                                  ),
                                  MyButton(text: 'Zamknij', onTap: () => Navigator.of(context).pop()),
                                ],
                              ),
                            ),
                          );
                        }
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