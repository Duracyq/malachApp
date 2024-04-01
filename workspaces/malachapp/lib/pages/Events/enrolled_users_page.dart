import 'package:flutter/material.dart';

class EnrolledUsersPage extends StatefulWidget {
  final String eventID;
  const EnrolledUsersPage({
    Key? key,
    required this.eventID,
  }) : super(key: key);
  @override
  _EnrolledUsersPageState createState() => _EnrolledUsersPageState();
}

class _EnrolledUsersPageState extends State<EnrolledUsersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enrolled Users'),
      ),
      body: Center(
        child: Text('Enrolled Users Page'),
      ),
    );
  }
}