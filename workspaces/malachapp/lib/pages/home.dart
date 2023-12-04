import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/topbar.dart';
import 'package:malachapp/services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
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
    tabs = [
      HomeHome(storage: storage, firebaseFirestore: firebaseFirestore, auth: auth),
      Container(),
      Container(),
    ];

    auth = AuthService();
    storage = Storage();
    firebaseFirestore = FirebaseFirestore.instance;
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: lightMode,
      // darkTheme: darkMode,
      home: Scaffold(
        appBar: const CustomAppBar(),
        body: tabs[_currentIndex],
        bottomNavigationBar: CurvedNavigationBar(
          buttonBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          animationDuration: const Duration(milliseconds: 200),
          color: const Color.fromRGBO(251, 133, 0, 1),
          backgroundColor: const Color.fromRGBO(255, 183, 3, 1),
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
      appBar: AppBar(
        title: const Text('HOME'),
        actions: <Widget>[
          IconButton(
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Center(
            child: Column(
              children: [
                // Retrieving photos from FirebaseStorage
                FutureBuilder(
                  future: storage.getImageUrls(),
                  builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                      return SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                                child: Image.network(
                              snapshot.data![index],
                              fit: BoxFit.cover,
                            ));
                          },
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting || !snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return Container();
                  },
                ),
                const SizedBox(height: 10),

                //text from Firestore Cloud DB
                StreamBuilder(
                  stream: firebaseFirestore.collection('test').snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((QueryDocumentSnapshot<Map<String, dynamic>> document) {
                        Map<String, dynamic> data = document.data();
                        return ListTile(
                          title: Text(data['test']),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
