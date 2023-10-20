import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/pages/home.dart';
import 'package:malachapp/pages/login.dart';

class FirebaseAuthPage extends StatefulWidget {
  const FirebaseAuthPage({super.key});
  @override
  State<FirebaseAuthPage> createState() => _FirebaseAuthPageState();
}

class _FirebaseAuthPageState extends State<FirebaseAuthPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          return const HomePage();
        }
        else { 
          return const LoginPage();
        }
      })
    );
  }
}
