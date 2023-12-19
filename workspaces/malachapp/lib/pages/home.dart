import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/reloadable_widget.dart';
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
  late PageController _pageController;
  late GlobalKey<CurvedNavigationBarState> _bottomNavBarKey;

  @override
  void initState() {
    super.initState();

    // Initialize auth, storage, and firebaseFirestore here
    auth = AuthService();
    storage = Storage();
    firebaseFirestore = FirebaseFirestore.instance;

    _pageController = PageController(initialPage: _currentIndex);
    _bottomNavBarKey = GlobalKey(); 

    // Now you can use these initialized values in the tabs list
    tabs = [
      HomeHome(
          storage: storage, firebaseFirestore: firebaseFirestore, auth: auth),
      const PollPage(),
      const EventListPage(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: Scaffold(
        appBar: const CustomAppBar(),
        body: PageView(
          controller: _pageController,
          children: tabs,
          onPageChanged: (index) {
            // swipe pages
            setState(() {
              _currentIndex = index;
              _bottomNavBarKey.currentState?.setPage(index);
            });
          },
        ),
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
          // swipe pages animation and BottomBar state change
          key: _bottomNavBarKey,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            });
          },
        ),
      ),
    );
  }
}
class HomeHome extends StatefulWidget {
  const HomeHome({
    Key? key,
    required this.storage,
    required this.firebaseFirestore,
    required this.auth,
  }) : super(key: key);

  final Storage storage;
  final FirebaseFirestore firebaseFirestore;
  final AuthService auth;

  @override
  State<HomeHome> createState() => _HomeHomeState();
}

class _HomeHomeState extends State<HomeHome> {
  late Future<List<String>> imageUrls;
  late Stream<QuerySnapshot<Map<String, dynamic>>> testData;

  @override
  void initState() {
    super.initState();
    // Initial loading of data
    imageUrls = widget.storage.getImageUrls();
    testData = widget.firebaseFirestore.collection('test').snapshots();
  }
  // refreshing the content
  Future<void> _refresh() async {
    // Reload data when the user performs a refresh gesture
    setState(() {
      imageUrls = widget.storage.getImageUrls();
      testData = widget.firebaseFirestore.collection('test').snapshots();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ReloadableWidget(
        onRefresh: _refresh,
        child: Column(
          children: [
            IconButton(
              icon: const Icon(Icons.power_settings_new_sharp),
              onPressed: () {
                widget.auth.signOut();
              },
            ),
            const SizedBox(height: 25),
            SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  children: [
                    FutureBuilder(
                      future: widget.storage.getImageUrls(),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<String>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          return SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Center(
                                  child: CachedNetworkImage(
                                    imageUrl: snapshot.data![index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.waiting ||
                            !snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return Container();
                      },
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder(
                      stream: widget.firebaseFirestore
                          .collection('test')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }

                        return Expanded(
                          child: ListView(
                            children: snapshot.data!.docs
                                .map(
                                    (QueryDocumentSnapshot<Map<String, dynamic>>
                                        document) {
                              Map<String, dynamic> data = document.data();
                              return ListTile(
                                title: Text(data['test']),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CreatorPage()));
        },
      ),
    );
  }
}
