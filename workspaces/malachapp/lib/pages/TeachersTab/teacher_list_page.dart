import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/text_field.dart';

class TeacherListPage extends StatefulWidget {
  @override
  State<TeacherListPage> createState() => _TeacherListPageState();
}

class _TeacherListPageState extends State<TeacherListPage> {
  TextEditingController teachersController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
        actions: [
          FutureBuilder(
            future: AuthService().isAdmin(),
            builder: (context, snapshot) {
              return Visibility(
                visible: snapshot.hasData && snapshot.data!,
                child: IconButton(
                  onPressed: () {
                    // Add teacher button tap
                  },
                  icon: const Icon(Icons.add),
                ),
              );
            }
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: teachers.length,
              itemBuilder: (context, index) {
                final teacher = teachers[index];
                if (teacher.name.toLowerCase().contains(teachersController.text.toLowerCase())) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(teacher.profileImage),
                    ),
                    title: Text(teacher.name),
                    subtitle: Text(teacher.subject),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Handle teacher item tap
                    },
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
          Container(
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
                      setState(() {
                        teachersController.text = value;
                      });
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
        ],
      ),
    );
  }
}

class Teacher {
  final String name;
  final String subject;
  final String profileImage;

  Teacher({required this.name, required this.subject, required this.profileImage});
}

List<Teacher> teachers = [
  Teacher(
    name: 'John Doe',
    subject: 'Mathematics',
    profileImage: 'https://example.com/john_doe.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  Teacher(
    name: 'Jane Smith',
    subject: 'Science',
    profileImage: 'https://example.com/jane_smith.jpg',
  ),
  
  // Add more teachers here
];