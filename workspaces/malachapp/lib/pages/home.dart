import 'package:firebase_admin/firebase_admin.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/topbar.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:malachapp/services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService auth = AuthService();
  final Storage storage = Storage();

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

          // https://www.youtube.com/watch?v=sM-WMcX66FI
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
                      return ElevatedButton(
                        onPressed: () {
                          // Handle button press, e.g., open the image
                        },
                        child: Image.network(
                          snapshot.data![index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
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
          )
        ],
      ),
    );
  }
}
