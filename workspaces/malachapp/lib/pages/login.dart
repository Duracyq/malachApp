// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/components/text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwController = TextEditingController();

  // void login() async {
  //   //show loading circle
  //   showDialog(
  //       context: context,
  //       builder: (context) => const Center(
  //             child: CircularProgressIndicator(),
  //           ));

  //   try {
  //     await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: loginController.text, password: passwController.text);
  //   } on FirebaseAuthException catch (e) {
  //     // showDialog(context:context, builder: (context) => Center(child: AboutDialog(children: [Text(e.message)]),));
  //     print(e.message);
  //   } finally {
  //     Navigator.of(context).pop();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle,
              size: 150,
            ),
            Text(
              "Logowanie",
            ),
            SizedBox(height: 100),
            MyTextField(
                hintText: "", obscureText: false, controller: loginController),
            const SizedBox(height: 10),
            MyTextField(
                hintText: "haslo",
                obscureText: false,
                controller: passwController),
            ElevatedButton(
              onPressed: () {
                // login();
              },
              child: const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
