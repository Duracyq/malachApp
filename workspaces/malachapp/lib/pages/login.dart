import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwController = TextEditingController();

  void login() async {
    //show loading circle 
    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator(),));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginController.text,
        password: passwController.text
        );
    } on FirebaseAuthException catch(e) {
      // showDialog(context:context, builder: (context) => Center(child: AboutDialog(children: [Text(e.message)]),));
      print(e.message);
    } finally {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: Center(child: Column(children: [
        TextField(controller: loginController, decoration: const InputDecoration(labelText: 'Login')),
        const SizedBox(height: 10),
        TextField(controller: passwController, decoration: const InputDecoration(labelText: 'Password'))
        ,
        ElevatedButton(
              onPressed: () {
                login();          
              },
              child: const Text('Login'),

        )
        ])
      )
    );
  }
}