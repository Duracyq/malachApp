import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admin/firebase_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:malachapp/auth/admin/admin_createuser_teacher.dart';
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

    String convertToRoman(String input) {
      return input.runes.map((rune) {
        switch(rune) {
          case 261: {
            return 'a';
          }
          case 263: {
            return 'c';
          }
          case 281: {
            return 'e';
          }
          case 322: {
            return 'l';
          }
          case 324: {
            return 'n';
          }
          case 243: {
            return 'o';
          }
          case 347: {
            return 's';
          }
          case 378: {
            return 'z';
          }
          case 380: {
            return 'z';
          }
          default: {
            return String.fromCharCode(rune);
          }
        }
      }).join().toLowerCase();
    }

    final String nameInRoman = convertToRoman(_nameController.text.toLowerCase());
    final String surnameInRoman = convertToRoman(_surnameController.text.toLowerCase());

    await db.collection('teachersList').add({
      'name': _nameController.text,
      'surname': _surnameController.text,
      'subject': _subjects,
      'accountMail': '$nameInRoman.$surnameInRoman@malachowianka.edu.pl',
    }).then((value) => debugPrint('Teacher added: ${_nameController.text} ${_surnameController.text}'));

    try {
      await createUser(nameInRoman, surnameInRoman);
    } on Exception catch (e) {
      debugPrint('Error: $e');
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

