import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WorkHoursCreator extends StatefulWidget {
  final teacherId;
  WorkHoursCreator({required this.teacherId});
  @override
  _WorkHoursCreatorState createState() => _WorkHoursCreatorState();
}

class _WorkHoursCreatorState extends State<WorkHoursCreator> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late var teacherId;
  @override
  void initState() {
    super.initState();
    teacherId = widget.teacherId;
    db.collection('teacherList').doc('teacherId').get().then((value) {
      setState(() {
        _workHours['Monday']['start'] = value['workHours']['Monday']['start'];
        _workHours['Monday']['end'] = value['workHours']['Monday']['end'];
        _workHours['Tuesday']['start'] = value['workHours']['Tuesday']['start'];
        _workHours['Tuesday']['end'] = value['workHours']['Tuesday']['end'];
        _workHours['Wednesday']['start'] = value['workHours']['Wednesday']['start'];
        _workHours['Wednesday']['end'] = value['workHours']['Wednesday']['end'];
        _workHours['Thursday']['start'] = value['workHours']['Thursday']['start'];
        _workHours['Thursday']['end'] = value['workHours']['Thursday']['end'];
        _workHours['Friday']['start'] = value['workHours']['Friday']['start'];
        _workHours['Friday']['end'] = value['workHours']['Friday']['end'];
      });
    });
  }
  String _getDayOfWeek(int index) {
    switch (index) {
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
  final Map<String, dynamic> _workHours = {
    'Monday': {
      'start': '',
      'end': '',
    },
    'Tuesday': {
      'start': '',
      'end': '',
    },
    'Wednesday': {
      'start': '',
      'end': '',
    },
    'Thursday': {
      'start': '',
      'end': '',
    },
    'Friday': {
      'start': '',
      'end': '',
    },
  };

  void _showTimePickerDialog(int index) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((selectedTime) {
      if (selectedTime != null) {
        setState(() {
          _workHours[_getDayOfWeek(index + 1)]['start'] =
              '${selectedTime.hour}:${selectedTime.minute}';
        });
      }
    }).then((_) => showTimePicker(context: context, initialTime: TimeOfDay.now()))
        .then((selectedTime) {
      if (selectedTime != null) {
        setState(() {
          _workHours[_getDayOfWeek(index + 1)]['end'] =
              '${selectedTime.hour}:${selectedTime.minute}';
        });
      }
    }).then((_) => db.collection('teacherList').doc('teacherId').update({
      'workHours': _workHours,
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work Hours Creator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_getDayOfWeek(index + 1)),
                    onTap: () {
                      _showTimePickerDialog(index);
                    },
                    subtitle: Column(
                      children: [
                        Text(
                          'Start time: ${_workHours[_getDayOfWeek(index + 1)]['start']}',
                        ),
                        Text(
                          'End time: ${_workHours[_getDayOfWeek(index + 1)]['end']}',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
