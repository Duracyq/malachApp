import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/topbar.dart';
import 'package:malachapp/services/storage_service.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';
import 'dart:ui' as ui;


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
      Container(),
      Container(),
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
            Icon(Icons.list_outlined),
            Icon(Icons.list_outlined),
            Icon(Icons.list_outlined),
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
    Key? key,
    required this.storage,
    required this.firebaseFirestore,
    required this.auth,
  }) : super(key: key);

  final Storage storage;
  final FirebaseFirestore firebaseFirestore;
  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.power_settings_new_sharp),
            onPressed: () {
              auth.signOut();
            },
          ),
          const SizedBox(height: 25),
          // Container - the test text is visible :)
          // ignore: sized_box_for_whitespace
          Container(
            height: 300,
            child: Center(
              child: Column(
                children: [
                  // Retrieving photos from FirebaseStorage
                  FutureBuilder(
                    future: storage.getImageUrls(),
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
                                  // Use CachedNetworkImage instead of Image.network
                                  imageUrl: snapshot.data![index],
<<<<<<< HEAD
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
=======
                                  // imageBuilder: (context, imageProvider) => Container(
                                  //   decoration: BoxDecoration(
                                  //     image: DecorationImage(
                                  //       image: imageProvider,
                                  //       fit: BoxFit.fitWidth,
                                  //     )
                                  //   ),
                                  // ),
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
>>>>>>> b9f3882c097825ebf4beeb2663d9e34aa0467c8d
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

                  // Text from Firestore Cloud DB
                  StreamBuilder(
                    stream: firebaseFirestore.collection('test').snapshots(),
<<<<<<< HEAD
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      return Expanded(
                        child: ListView(
                          children: snapshot.data!.docs.map(
                              (QueryDocumentSnapshot<Map<String, dynamic>>
                                  document) {
=======
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
          
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
          
                      return Expanded(
                        child: ListView(
                          children: snapshot.data!.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> document) {
>>>>>>> b9f3882c097825ebf4beeb2663d9e34aa0467c8d
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
          )
        ],
      ),
    );
  }
}
