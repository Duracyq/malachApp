import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';


class AddTeacherToListPage extends StatefulWidget {
  @override
  _AddTeacherToListPageState createState() => _AddTeacherToListPageState();
}

class _AddTeacherToListPageState extends State<AddTeacherToListPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  List<String> _subjects= [];
  final Logger logger = Logger();

  List subjects = [
    {
      "display": "Matematyka",
      "value": "Matematyka",
    },
    {
      "display": "Język Polski",
      "value": "Język Polski",
    },
    {
      "display": "Angielski",
      "value": "Angielski",
    },
    {
      "display": "Historia",
      "value": "Historia",
    },
    {
      "display": "Fizyka",
      "value": "Fizyka",
    },
    {
      "display": "Chemia",
      "value": "Chemia",
    },
    {
      "display": "Biologia",
      "value": "Biologia",
    },
    {
      "display": "Geografia",
      "value": "Geografia",
    },
    {
      "display": "Informatyka",
      "value": "Informatyka",
    },
    {
      "display": "Wychowanie Fizyczne",
      "value": "Wychowanie Fizyczne",
    },
    {
      "display": "Muzyka",
      "value": "Muzyka",
    },
    {
      "display": "Edukacja dla bezpieczeństwa",
      "value": "Edukacja dla bezpieczeństwa",
    },
    {
      "display": "Etyka",
      "value": "Etyka",
    },
    {
      "display": "Religia",
      "value": "Religia",
    },
    {
      "display": "Podstawy Przedsiębiorczości",
      "value": "Podstawy Przedsiębiorczości",
    }
    
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   _subjects = [];
  // }

  Future<void> _addTeacher() async {
    final db = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance;
    await db.collection('teachersList').add({
      'name': _nameController.text,
      'surname': _surnameController.text,
      'subject': _subjects,
      'accountMail': '${_nameController.text.toLowerCase()}.${_surnameController.text.toLowerCase()}@malachowianka.edu.pl',
    }).then((value) => debugPrint('Teacher added: ${_nameController.text} ${_surnameController.text}'));
    if (_nameController.text.isNotEmpty && _surnameController.text.isNotEmpty) {
      final user = db.collection('teachersList').where('accountMail', isEqualTo: '${_nameController.text.toLowerCase()}.${_surnameController.text.toLowerCase()}@malachowianka.edu.pl').get().then((value) => debugPrint('Teacher exists: ${_nameController.text} ${_surnameController.text}'));
      if (user == null) {
        await auth.createUserWithEmailAndPassword(
          email: '${_nameController.text.toLowerCase()}.${_surnameController.text.toLowerCase()}@malachowianka.edu.pl',
          password: '${_nameController.text.toLowerCase()}.${_surnameController.text.toLowerCase()}',
        ).then((value) => debugPrint('User created: ${_nameController.text.toLowerCase()}.${_surnameController.text.toLowerCase()}@malachowianka.edu.pl'));
      } else {
        debugPrint('User already exists: ${_nameController.text.toLowerCase()}.${_surnameController.text.toLowerCase()}@malachowianka.edu.pl');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj Nauczyciela do Listy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: MyTextField(hintText: 'Imię', controller: _nameController),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: MyTextField(hintText: 'Nazwisko', controller: _surnameController),
              ),
              Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: MultiSelectFormField(
                autovalidate: AutovalidateMode.disabled,
                title: const Text('Przedmioty'),
                validator: (value) {
                  if (value == null || value.length == 0) {
                    return 'Wybierz jeden lub więcej przedmiotów';
                  }
                  return null;
                },
                dataSource: subjects,
                textField: 'display',
                valueField: 'value',
                okButtonLabel: 'OK',
                cancelButtonLabel: 'ANULUJ',
                hintWidget: const Text('Wybierz jeden lub więcej'),
                initialValue: _subjects,
                onSaved: (value) {
                  if (value == null) return;
                  logger.d(value);
                  setState(() {
                    _subjects = List<String>.from(value);
                  });
                  logger.d(_subjects);
                },
                
              ),
            ),
            MyButton(
              text: 'Dodaj',
              onTap: () {
                  if (_subjects.isNotEmpty) {
                    _addTeacher();
                    Navigator.of(context).pop();
                  } else {
                    debugPrint('Nie wybrano przedmiotów');
                    logger.d(_subjects);
                    return;
                  }
            })
          ],
        ),
      ),
    );
  }
}

