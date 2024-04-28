import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:malachapp/pages/TeachersTab/add_teacher_to_the_list.dart';

class TeacherListPage extends StatefulWidget {
  @override
  State<TeacherListPage> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  TextEditingController teachersController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _db = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
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
                                if (mapData['name'].toLowerCase().contains(teachersController.text.toLowerCase())) {
                                  return ListTile(
                                    // leading: CircleAvatar(
                                    //   backgroundImage: NetworkImage(teacher.profileImage),
                                    // ),
                                    title: Text('${mapData['name']} ${mapData['surname']}'),
                                      subtitle: Text(mapData['subject'].join(', ')),
                                    trailing: const Icon(Icons.arrow_forward),
                                    onTap: () {
                                      // Handle teacher item tap
                                    },
                                  );
                                } else {
                                  return const SizedBox.shrink();
                                }
                              }
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
                      hintText: 'Search teachers',
                      controller: teachersController,
                      onChanged: (value) {
                        setState(() {});
                      },
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