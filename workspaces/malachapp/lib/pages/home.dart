import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/MyText1.dart';
import 'package:malachapp/components/drawer.dart';
import 'package:malachapp/components/reloadable_widget.dart';
import 'package:malachapp/components/topbar.dart';
import 'package:malachapp/pages/Events/event_design.dart';
import 'package:malachapp/pages/Home/post_creator.dart';
import 'package:malachapp/pages/creator.dart';
import 'package:malachapp/pages/event_page.dart';
import 'package:malachapp/pages/Home/home_home.dart';
import 'package:malachapp/pages/message_broadcast_page.dart';
import 'package:malachapp/pages/Poll/poll_list_design.dart';
// import 'package:malachapp/pages/home_home.dart';
import 'package:malachapp/pages/Poll/poll_page.dart';
import 'package:malachapp/pages/notification_archive.dart';
import 'package:malachapp/services/fb_storage_loader.dart';
import 'package:malachapp/services/notification_service.dart';
// import 'package:malachapp/services/notification_service.dart';
import 'package:malachapp/services/storage_service.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

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
  late GlobalKey<CurvedNavigationBarState> _bottomNavBarKey;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Initialize auth, storage, and firebaseFirestore here
    auth = AuthService();
    storage = Storage();
    firebaseFirestore = FirebaseFirestore.instance;

    _bottomNavBarKey = GlobalKey();

    // Now you can use these initialized values in the tabs list
    tabs = [
      const HomeHomeWidget(
          // storage: storage, firebaseFirestore: firebaseFirestore, auth: auth
          ),
      const PollDesign(),
      //const EventListPage(),
      EventList(),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: CustomAppBar(),
        drawer: null,
        endDrawer: CustomDrawer(),
        body: IndexedStack(
          index: _currentIndex,
          children: tabs,
        ),
        bottomNavigationBar: Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) => CurvedNavigationBar(
            animationDuration: const Duration(milliseconds: 200),
            color: themeProvider.themeData
                .primaryColor, // Ustaw kolor elementów nawigacji na podstawie aktualnego motywu
            backgroundColor: themeProvider.themeData.colorScheme
                .background, // Ustaw kolor tła na podstawie aktualnego motywu
            height: 49,
            items: const [
              Icon(Icons.home_rounded),
              Icon(Icons.poll),
              Icon(Icons.calendar_month),
            ],
            key: _bottomNavBarKey,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
        ),

        // bottomNavigationBar: CurvedNavigationBar(
        //   //buttonBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
        //   animationDuration: const Duration(milliseconds: 200),
        //   color: Theme.of(context).colorScheme.secondary,
        //   backgroundColor: Theme.of(context).colorScheme.background,
        //   height: 49,
        //   items: const [
        //     Icon(Icons.home_rounded),
        //     Icon(Icons.poll),
        //     Icon(Icons.calendar_month),
        //   ],
        //   // swipe pages animation and BottomBar state change
        //   key: _bottomNavBarKey,
        //   onTap: (index) {
        //     setState(() {
        //       _currentIndex = index;
        //     });
        //   },
        // ),

        floatingActionButton: FutureBuilder(
          future: auth.isAdmin(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            if (snapshot.hasError) {
              return const Text('Wystąpił błąd');
            }

            if (snapshot.data == true) {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostCreator(),
                    ),
                  );
                },
                child: const Icon(Icons.add),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// class HomeHome extends StatefulWidget {
//   HomeHome({
//     super.key,
//     // required this.storage,
//     // required this.firebaseFirestore,
//     // required this.auth,
//   });

//   // final Storage storage;
//   // final FirebaseFirestore firebaseFirestore;
//   // final AuthService auth;

//   @override
//   State<HomeHome> createState() => _HomeHomeState();
// }

// class _HomeHomeState extends State<HomeHome> {
//   // late Future<List<String>> imageUrls;
//   // late Stream<QuerySnapshot<Map<String, dynamic>>> testData;
//   // late PageController _pageController;
//   // int totalPage = 4;

//   @override
//   // void initState() {
//   // super.initState()
//   // Initial loading of data
//   // imageUrls = widget.storage.getImageUrls('test');
//   // testData = widget.firebaseFirestore.collection('test').snapshots();

//   // _pageController = PageController(
//   //   initialPage: 0,
//   //   ..addListener(_onScroll);
//   // }

// // refreshing the content
//   // Future<void> _refresh() async {
//   // Reload data when the user performs a refresh gesture
//   //   setState(() {
//   //     imageUrls = widget.storage.getImageUrls('test');
//   //     testData = widget.firebaseFirestore.collection('test').snapshots();
//   //   });
//   // }

//   // void _onScroll() {}

//   // @override
//   // void dispose() {
//   //   _pageController.dispose();
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: Column(
//         children: [
//           // const SizedBox(height: 15),
//           Column(
//             children: [
//               // StorageLoader(storage: widget.storage, uri: 'test'),
//               // const SizedBox(height: 10),
//               // StreamBuilder(
//               //   stream: widget.firebaseFirestore
//               //       .collection('test')
//               //       .snapshots(),
//               //   builder: (BuildContext context,
//               //       AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
//               //           snapshot) {
//               //     if (snapshot.hasError) {
//               //       return Text('Error: ${snapshot.error}');
//               //     }

//               //     if (snapshot.connectionState ==
//               //         ConnectionState.waiting) {
//               //       return const CircularProgressIndicator();
//               //     }

//               //     return Expanded(
//               //       child: ListView(
//               //         children: snapshot.data!.docs.map(
//               //             (QueryDocumentSnapshot<Map<String, dynamic>>
//               //                 document) {
//               //           Map<String, dynamic> data = document.data();
//               //           return ListTile(
//               //             title: Text(data['test']),
//               //           );
//               //         }).toList(),
//               //       ),
//               //     );
//               //   },
//               // ),
//               // ElevatedButton(
//               //     onPressed: () {
//               //       notificationService.showNotification(
//               //         title: 'New Notification',
//               //         body: 'This is a notification message.',
//               //       );
//               //     },
//               //     child: Text('Show Notification'),
//               //   ),
//               Padding(
//                 padding: const EdgeInsets.all(12),
//                 child: SizedBox(
//                   width: screenWidth,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const MyText(
//                           text: "Dołącz do naszej szkolnej społeczności!",
//                           rozmiar: 16,
//                           waga: FontWeight.w400),
//                       Row(
//                         children: [
//                           const MyText(
//                               text: "Witaj ",
//                               rozmiar: 26,
//                               waga: FontWeight.w700),
//                           Text(
//                             "Amelka",
//                             style: GoogleFonts.nunito(
//                               textStyle: const TextStyle(
//                                   fontFamily: 'Nunito',
//                                   fontStyle: FontStyle.normal,
//                                   fontSize: 26,
//                                   fontWeight: FontWeight.w700),
//                             ),
// // =======
// //       body: ReloadableWidget(
// //         onRefresh: _refresh,
// //         child: Column(
// //           children: [
// //             const SizedBox(height: 25),
// //             SizedBox(
// //               height: 300,
// //               child: Center(
// //                 child: Column(
// //                   children: [
// //                     // limit user
// //                     if(FirebaseAuth.instance.currentUser?.email == "00011@malach.com")
// //                       Column(
// //                         children: [
// //                           TextButton(
// //                               onPressed: () => Navigator.of(context).push(
// //                                   MaterialPageRoute(
// //                                       builder: (context) => MessageBroadcastPage())),
// //                               child: const Text("Send Message Page")),
// //                           TextButton(
// //                             onPressed: () async {
// //                               await NotificationService()
// //                                   .requestNotificationPermission();
// //                             },
// //                             child: const Text('Request Notification Permission'),
// //                           ),
// //                         ],
// //                       ),
// //                       // Example usage in a Flutter widget
// //                     StorageLoader(storage: widget.storage, uri: 'test'),
// //                     const SizedBox(height: 10),
// //                     StreamBuilder(
// //                       stream: widget.firebaseFirestore
// //                           .collection('test')
// //                           .snapshots(),
// //                       builder: (BuildContext context,
// //                           AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
// //                               snapshot) {
// //                         if (snapshot.hasError) {
// //                           return Text('Error: ${snapshot.error}');
// //                         }

// //                         if (snapshot.connectionState ==
// //                             ConnectionState.waiting) {
// //                           return const CircularProgressIndicator();
// //                         }

// //                         return Expanded(
// //                           child: ListView(
// //                             children: snapshot.data!.docs.map(
// //                                 (QueryDocumentSnapshot<Map<String, dynamic>>
// //                                     document) {
// //                               Map<String, dynamic> data = document.data();
// //                               return ListTile(
// //                                 title: Text(data['test']),
// //                               );
// //                             }).toList(),
// // >>>>>>> main
//                           ),
//                           Text(
//                             "!",
//                             style: GoogleFonts.nunito(
//                               textStyle: const TextStyle(
//                                   fontFamily: 'Nunito',
//                                   fontStyle: FontStyle.normal,
//                                   fontSize: 26,
//                                   fontWeight: FontWeight.w700),
//                             ),
//                           )
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('wydarzenia')
//                       .snapshots(),
//                   builder: (BuildContext context,
//                       AsyncSnapshot<QuerySnapshot> snapshot) {
//                     if (snapshot.hasError) {
//                       return Text('Wystąpił błąd');
//                     }

//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Text("Ładowanie...");
//                     }

//                     return ListView(
//                       scrollDirection: Axis.horizontal,
//                       children:
//                           snapshot.data!.docs.map((DocumentSnapshot document) {
//                         return Card(
//                           child: Column(
//                             children: <Widget>[
//                               // CachedNetworkImage(
//                               //   //imageUrl: document.data()!['glowne_zdjecie'],
//                               //   placeholder: (context, url) =>
//                               //       CircularProgressIndicator(),
//                               //   errorWidget: (context, url, error) =>
//                               //       Icon(Icons.error),
//                               // ),
//                               // ListTile(
//                               //   title: Text(document.data()['nazwa']),
//                               //   subtitle: Text(document.data()['opis']),
//                               // ),
//                               // Wrap(
//                               //   children: document
//                               //       .data()['reszta_zdjec']
//                               //       .map<Widget>((url) {
//                               //     return CachedNetworkImage(
//                               //       imageUrl: url,
//                               //       placeholder: (context, url) =>
//                               //           CircularProgressIndicator(),
//                               //       errorWidget: (context, url, error) =>
//                               //           Icon(Icons.error),
//                               //     );
//                               //   }).toList(),
//                               // ),
//                             ],
//                           ),
//                           color: Colors.white,
//                         );
//                       }).toList(),
//                     );
//                   },
//                 ),
//               )
//             ],
//           ),
//         ],
//       ),
//       
//   }
// }
