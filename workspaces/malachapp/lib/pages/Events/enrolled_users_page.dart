import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/services/nickname_fetcher.dart';

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
        title: const Text('Zgłoszeni Użytkownicy'),
      ),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventID)
            .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Coś poszło nie tak');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (!snapshot.hasData) {
              return const Text('Brak danych');
            }

            final memberData = snapshot.data!.data() as Map<String, dynamic>;
            final members = (memberData['enrolledUsers'] as List);

           return ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
                  return ListTile(
                    title: buildNickname(context, members[index]),
                    subtitle: Text(
                      members[index]
                    ),
                  );
                }
              );
            },
          ),
      )
    );
  }

  Widget buildNickname(BuildContext context, String email) {
    return FutureBuilder<String>(
      future: AuthService().getUserIdFromEmail(email),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Błąd: ${snapshot.error}');
        } else {
          return FutureBuilder<String>(
            future: NicknameFetcher().fetchNickname(snapshot.data!).first,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasError) {
                return Text('Błąd: ${snapshot.error}');
              } if (snapshot.data == null) {
                return Text(email);
              } else {
                return Text(snapshot.data!);
              }
            },
          );
        }
      },
    );
  }
}