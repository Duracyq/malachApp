import 'package:cloud_firestore/cloud_firestore.dart';
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
  final AuthService auth = AuthService();
  final Storage storage = Storage();
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

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
          const TopBarFb2(title: 'title', upperTitle: 'upperTitle'),
          Center(child: Column(children: [
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
                            // width: 100,
                            // height: 100,
                            fit: BoxFit.cover,
                          )
                        );
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
            const SizedBox(height:10),

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
          ]),
          )
        ],
      ),
    );
  }
}
