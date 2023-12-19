import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/topbar.dart';
import 'package:malachapp/pages/creator.dart';
import 'package:malachapp/pages/event_page.dart';
import 'package:malachapp/pages/poll_page.dart';
import 'package:malachapp/services/storage_service.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AuthService auth;
  late Storage storage;
  late FirebaseFirestore firebaseFirestore;

  int _currentIndex = 0;
  late List<Widget> tabs;

  @override
  void initState() {
    super.initState();

    // Initialize auth, storage, and firebaseFirestore here
    auth = AuthService();
    storage = Storage();
    firebaseFirestore = FirebaseFirestore.instance;

    // Now you can use these initialized values in the tabs list
    tabs = [
      HomeHome(
          storage: storage, firebaseFirestore: firebaseFirestore, auth: auth),
      const PollPage(),
      const EventListPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: Scaffold(
        appBar: const CustomAppBar(),
        body: tabs[_currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          buttonBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          animationDuration: const Duration(milliseconds: 200),
          color: Theme.of(context).colorScheme.secondary,
          backgroundColor: Theme.of(context).colorScheme.background,
          height: 49,
          items: const [
            Icon(Icons.home_rounded),
            Icon(Icons.poll),
            Icon(Icons.calendar_month),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class HomeHome extends StatelessWidget {
  const HomeHome({
    super.key,
    required this.storage,
    required this.firebaseFirestore,
    required this.auth,
  });

  final Storage storage;
  final FirebaseFirestore firebaseFirestore;
  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EventList(),

      // Column(
      //   children: [
      //     IconButton(
      //       icon: const Icon(Icons.power_settings_new_sharp),
      //       onPressed: () {
      //         auth.signOut();
      //       },
      //     ),
      //     const SizedBox(height: 25),
      //     // Container - the test text is visible :)
      //     // ignore: sized_box_for_whitespace
      //     Container(
      //       height: 300,
      //       child: Center(
      //         child: Column(
      //           children: [
      //             // Retrieving photos from FirebaseStorage
      //             FutureBuilder(
      //               future: storage.getImageUrls(),
      //               builder: (BuildContext context,
      //                   AsyncSnapshot<List<String>> snapshot) {
      //                 if (snapshot.connectionState == ConnectionState.done &&
      //                     snapshot.hasData) {
      //                   return SizedBox(
      //                     height: 100,
      //                     child: ListView.builder(
      //                       scrollDirection: Axis.horizontal,
      //                       shrinkWrap: true,
      //                       itemCount: snapshot.data!.length,
      //                       itemBuilder: (BuildContext context, int index) {
      //                         return Center(
      //                           child: CachedNetworkImage(
      //                             // Use CachedNetworkImage instead of Image.network
      //                             imageUrl: snapshot.data![index],
      //                             // imageBuilder: (context, imageProvider) => Container(
      //                             //   decoration: BoxDecoration(
      //                             //     image: DecorationImage(
      //                             //       image: imageProvider,
      //                             //       fit: BoxFit.fitWidth,
      //                             //     )
      //                             //   ),
      //                             // ),
      //                             fit: BoxFit.cover,
      //                             placeholder: (context, url) =>
      //                                 const CircularProgressIndicator(),
      //                             errorWidget: (context, url, error) =>
      //                                 const Icon(Icons.error),
      //                           ),
      //                         );
      //                       },
      //                     ),
      //                   );
      //                 }
      //                 if (snapshot.connectionState == ConnectionState.waiting ||
      //                     !snapshot.hasData) {
      //                   return const CircularProgressIndicator();
      //                 }
      //                 return Container();
      //               },
      //             ),
      //             const SizedBox(height: 10),
      //             // Text from Firestore Cloud DB
      //             StreamBuilder(
      //               stream: firebaseFirestore.collection('test').snapshots(),
      //               builder: (BuildContext context,
      //                   AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
      //                       snapshot) {
      //                 if (snapshot.hasError) {
      //                   return Text('Error: ${snapshot.error}');
      //                 }

      //                 if (snapshot.connectionState == ConnectionState.waiting) {
      //                   return const CircularProgressIndicator();
      //                 }

      //                 return Expanded(
      //                   child: ListView(
      //                     children: snapshot.data!.docs.map(
      //                         (QueryDocumentSnapshot<Map<String, dynamic>>
      //                             document) {
      //                       Map<String, dynamic> data = document.data();
      //                       return ListTile(
      //                         title: Text(data['test']),
      //                       );
      //                     }).toList(),
      //                   ),
      //                 );
      //               },
      //             ),
      //           ],
      //         ),
      //       ),
      //     )
      //   ],
      // ),

      // kreator postów
      floatingActionButton: FloatingActionButton(onPressed: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const CreatorPage()));
      }),
    );
  }
}

class EventList extends StatefulWidget {
  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.jumpTo(_controller.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('wydarzenia')
          .orderBy('data')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var events = snapshot.data?.docs;

        return ListView.builder(
          controller: _controller,
          itemCount: events?.length,
          itemBuilder: (context, index) {
            var event = events?[index].data() as Map<String, dynamic>;
            return EventCard(
              title: event['tytul'],
              date: event['data'],
            );
          },
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final String title;
  final DateTime date;

  const EventCard({Key? key, required this.title, required this.date})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Text(title),
        subtitle: Text(date.toString()),
        // You can add more information about the event here
      ),
    );
  }
}

// class EventList extends StatelessWidget {
  
//   final ScrollController _controller = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _controller.jumpTo(_controller.position.maxScrollExtent);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: FirebaseFirestore.instance
//           .collection('wydarzenia')
//           .orderBy('data')
//           .snapshots(),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return CircularProgressIndicator();
//         }

//         var events = snapshot.data?.docs;

//         return ListView.builder(
//           itemCount: events?.length,
//           itemBuilder: (context, index) {
//             var event = events?[index].data() as Map<String, dynamic>;
//             return EventCard(
//               title: event['tytul'],
//               date: event['data'],
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class EventCard extends StatelessWidget {
//   final String title;
//   final DateTime date;

//   const EventCard({super.key, required this.title, required this.date});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(10),
//       child: ListTile(
//         title: Text(title),
//         subtitle: Text(date.toString()),
//         // Tutaj możesz dodać więcej informacji o wydarzeniu
//       ),
//     );
//   }
// }


// final ScrollController _controller = ScrollController();

// @override
// void initState() {
//   super.initState();
//   _controller.jumpTo(_controller.position.maxScrollExtent);
// }

// // ...

// ListView.builder(
//   controller: _controller,
//   // reszta kodu
// )
