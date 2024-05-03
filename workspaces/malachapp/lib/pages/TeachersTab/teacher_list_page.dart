import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/pages/TeachersTab/add_teacher_to_the_list.dart';
import 'package:malachapp/pages/TeachersTab/teacher_tab.dart';

class TeacherListPage extends StatefulWidget {
  @override
  State<TeacherListPage> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  TextEditingController teachersController = TextEditingController();

  bool isAnyMapDataTrue(Map<String, dynamic> mapData) {
    bool isTrue = mapData['name'].toLowerCase().contains(teachersController.text.toLowerCase())
      || mapData['surname'].toLowerCase().contains(teachersController.text.toLowerCase())
      || mapData['subject'].join(', ').toLowerCase().contains(teachersController.text.toLowerCase());
    return isTrue;
  }
  List<String> subjects = [
    'Matematyka',
    'Język Polski',
    'Angielski',
    'Historia',
    'Fizyka',
    'Chemia',
    'Biologia',
    'Geografia',
    'Informatyka',
    'Wychowanie Fizyczne',
    'Muzyka',
    'Edukacja dla bezpieczeństwa',
    'Etyka',
    'Religia',
    'Podstawy Przedsiębiorczości',
  ];

  @override
  Widget build(BuildContext context) {
    final _db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nauczyciele'),
        actions: [
          FutureBuilder<bool>(
            future: AuthService().isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AddTeacherToListPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Filtruj według przedmiotu'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for(var value in subjects)
                            ListTile(
                              title: Text(value),
                              onTap: () {
                                Navigator.of(context).pop(value);
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ).then((selectedSubject) {
                if (selectedSubject != null) {
                  setState(() {
                    teachersController.clear();
                    teachersController.text = selectedSubject;
                  });
                }
              });
            },
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Stack(
          children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: _db.collection('teachersList').snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    return SingleChildScrollView( // Wrap with SingleChildScrollView
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true, // Add this line
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              final data = snapshot.data?.docs[index].data();
                              // final teacher = teachers[index];
                              if(data != null) {
                                final mapData = data as Map<String, dynamic>;
                                if (isAnyMapDataTrue(mapData)) {
                                  return ListTile(
                                    // leading: CircleAvatar(
                                    //   backgroundImage: NetworkImage(teacher.profileImage),
                                    // ),
                                    title: Text('${mapData['name']} ${mapData['surname']}'),
                                      subtitle: Text(mapData['subject'].join(', ')),
                                    trailing: const Icon(Icons.arrow_forward),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => TeacherTab(teacherSnapshot: snapshot.data!.docs[index], teacherId: snapshot.data!.docs[index].id)
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }
                              // return const SizedBox.shrink();
                            },
                          ),                
                        ],
                      ),
                    );
                  }
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 10,
            right: 10,
            child: Container(
              color: Colors.transparent,
              margin: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: MyTextField(
                      hintText: 'Szukaj',
                      controller: teachersController,
                      onChanged: (value) {
                        setState(() {});
                      },
                      icon: const Icon(Icons.search),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      onPressed: () {
                        teachersController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}