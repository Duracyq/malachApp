import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart';
import 'package:malachapp/components/topbar.dart';
import 'package:firebase_storage/firebase_storage.dart' as f_storage;
import 'package:malachapp/services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService auth = AuthService();

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
          TopBarFb2(title: 'title', upperTitle: 'upperTitle'),
          FutureBuilder<f_storage.ListResults>(
            future: storage.listFiles(), // Make sure 'storage' is properly initialized
            builder: (BuildContext context, AsyncSnapshot<f_storage.ListResults> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While the Future is still running, show a loading indicator or text.
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // If the Future throws an error, display an error message.
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.hasData) {
                // If the Future is complete and has data, display it here.
                final data = snapshot.data;
                // You can render the data as needed.
                return Text('Data: $data');
              } else {
                // By default, show an empty container.
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
