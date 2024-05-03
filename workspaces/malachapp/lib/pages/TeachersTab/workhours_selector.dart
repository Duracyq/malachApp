import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malachapp/components/my_button.dart';

class WorkHoursCreator extends StatefulWidget {
  final String teacherId;
  const WorkHoursCreator({super.key, required this.teacherId});
  @override
  _WorkHoursCreatorState createState() => _WorkHoursCreatorState();
}

class _WorkHoursCreatorState extends State<WorkHoursCreator> {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late String teacherId;
  @override
  void initState() {
    super.initState();
    teacherId = widget.teacherId;
    db.collection('teacherList').doc(teacherId).get().then((value) {
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
      helpText: 'Start time',
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },

    ).then((selectedTime) {
      if (selectedTime != null) {
        setState(() {
          _workHours[_getDayOfWeek(index + 1)]['start'] =
              '${selectedTime.hour}:${selectedTime.minute}';
        });
      }
    }).then((_) => showTimePicker(context: context, initialTime: TimeOfDay.now(), helpText: 'End time', builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },)).then((selectedTime) {
        if (selectedTime != null) {
          setState(() {
            _workHours[_getDayOfWeek(index + 1)]['end'] = '${selectedTime.hour}:${selectedTime.minute}';
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
        actions: [
          IconButton(onPressed: () => showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Jak używać?'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: const WorkHoursInstructions()),
                  const SizedBox(height: 20.0),
                  Align(
                    alignment: Alignment.center,
                    child: MyButton(
                      onTap: () => Navigator.of(context).pop(),
                      text: 'Zamknij',
                    ),
                  ),
                ],
                ),
              scrollable: false,
            ),
          ), icon: const Icon(Icons.help)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Expanded(child: const WorkHoursInstructions()),
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
            MyButton(
              onTap: () {
                db.collection('teacherList').doc('teacherId').update({
                  'workHours': _workHours,
                }).then((value) => Navigator.of(context).pop());
              },
              text: 'Save',
            ),
          ],
        ),
      ),
    );
  }
}

class WorkHoursInstructions extends StatelessWidget {
  const WorkHoursInstructions({Key? key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ustaw godziny pracy:',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  '📅 Zobaczysz listę dni (od poniedziałku do piątku).',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10),
                Text(
                  '👉 Dotknij dnia, dla którego chcesz ustawić godziny pracy.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10),
                Text(
                  '🕒 Wyskoczy okno, w którym zostaniesz poproszony o wybranie godziny rozpoczęcia. Wybierz godziny rozpoczęcia pracy dla tego dnia.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10),
                Text(
                  '🔚 Pojawi się kolejne okno do wyboru godziny zakończenia. Wybierz godziny zakończenia pracy dla tego dnia.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10),
                Text(
                  '🔄 Powtórz dla innych dni: Postępuj tak samo dla każdego dnia, dla którego chcesz ustawić godziny pracy.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Text(
            '💾 Zapisz: Gdy ustalisz godziny pracy dla wszystkich dni, poszukaj przycisku oznaczonego jako "Zapisz". Wciśnij go, aby zapisać zmiany.',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
