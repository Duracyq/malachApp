//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:malachapp/components/herb.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:google_fonts/google_fonts.dart';

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
            Container(child: Herb()),
            Text(
              "Logowanie",
              style: GoogleFonts.roboto(
                // Ustawienie czcionki Open Sans
                textStyle: const TextStyle(
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
              child: MyTextField(
                  hintText: "login",
                  obscureText: false,
                  controller: loginController),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: MyTextField(
                  hintText: "haslo",
                  obscureText: false,
                  controller: passwController),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12, left: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Zapomniałeś hasła?",
                      style: GoogleFonts.roboto(
                        // Ustawienie czcionki Open Sans
                        textStyle: TextStyle(
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  // login();
                },
                child: Text(
                  'Login',
                  // style:
                  //     TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
