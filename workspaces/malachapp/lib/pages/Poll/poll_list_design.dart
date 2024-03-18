import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/MyText.dart';
import 'package:malachapp/pages/Poll/poll.dart';
import 'package:malachapp/pages/Poll/poll_page.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

class PollDesign extends StatelessWidget {
  const PollDesign({super.key});

  Widget buildPollList(
      BuildContext context, 
      double screenWidth, 
      double screenHeight, 
      int index, 
      int? howManyQuestions,
      String? pollListTitle,
      String pollListId,
    ) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(0),
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PollDesign1(
                  pollListTitle: pollListTitle.toString(),
                  pollCount: howManyQuestions!,
                  pollListId: pollListId,
                ),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                height: screenHeight * 0.1,
                width: screenWidth * 0.9,
                margin: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: Provider.of<ThemeProvider>(context).themeData == darkMode
                      ? Colors.grey[700]
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Provider.of<ThemeProvider>(context).themeData == darkMode
                          ? Colors.grey[750]!.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: MyText(
                    text: pollListTitle ?? '', // Updated text
                    rozmiar: 22,
                    waga: FontWeight.w700,
                  ),
                ),
              ),
              Positioned(
                right: 5,
                top: 12,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Provider.of<ThemeProvider>(context).themeData == darkMode
                        ? Colors.grey[600]
                        : Colors.grey[200],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$howManyQuestions', // Updated text
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Design'),
        actions: [
          FutureBuilder<bool>(
            future: AuthService().isAdmin(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                return IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PollCreatorPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                );
              } else {
                return const SizedBox.shrink(); // Hide the icon if not an admin
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _PollListViewerState(),
          ),
        ],
      ),
    );
  }
}

class _PollListViewerState extends StatelessWidget {
  _PollListViewerState();
  final _db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: RefreshIndicator(
        onRefresh: () => Future.delayed(Duration.zero), // Placeholder for actual refresh function
        child: StreamBuilder<QuerySnapshot>(
          stream: _db.collection('pollList').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final pollDocs = snapshot.data!.docs;
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;
            return ListView.builder(
              itemCount: pollDocs.length,
              itemBuilder: (context, index) {
                final pollDoc = pollDocs[index];
                final pollTitle = pollDoc['pollListTitle'];
                return FutureBuilder<QuerySnapshot>(
                future: _db.collection('pollList').doc(pollDoc.id).collection('polls').get(),
                  builder: (context, pollListSnapshot) {
                    if (pollListSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final pollListLength = pollListSnapshot.data!.docs.length;
                    return PollDesign().buildPollList(
                      context,
                      screenWidth,
                      screenHeight,
                      index,
                      pollListLength,
                      pollTitle as String?,
                      pollDoc.id // Added type casting
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
