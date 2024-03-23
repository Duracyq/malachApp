import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:malachapp/auth/auth_service.dart' as auth;
import 'package:flutter/material.dart';
import 'package:malachapp/components/herb.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malachapp/components/my_button.dart';
import 'package:malachapp/pages/reset_hasla.dart';
import 'package:malachapp/services/set_user.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/light_mode.dart';
/*
  Ludzie beda dostawali token weryfikacyjny aby grupować chujkow do klasy.
  Login to nazwa emailu
  Wzór: login@malach.com
  Passw: Cezar z loginu o przesunieciu +1789
*/

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwController = TextEditingController();
  final auth.AuthService _authService = auth.AuthService();
  // ignore: unused_field
  auth.AuthStatus _loginStatus = auth.AuthStatus.unknown;

  Future<void> performLogin() async {
    try {
      print('Before login');
      showDialog(
        context: context,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      await _authService.login(
        login: loginController.text,
        password: passwController.text,
      );
      print('After login');
      // await setUser(); // Ensure that setUser is called after successful login
      setState(() {
        _loginStatus = auth.AuthStatus.unknown;
      });
      print('After setUser');
    } on auth.AuthExceptionHandler catch (e) {
      print('Login error: $e'); // Handle authentication exceptions
    } finally {
      Navigator.of(context).pop();
    }
  }



  @override
  Widget build(BuildContext context) {
    bool isChecked = false;

    void onChanged(bool value) {
      debugPrint('Checkbox value: $value');
      setState(() {
        isChecked = value;
      });
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      darkTheme: darkMode,
      home: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Herb(), //? nie ma różnicy czy z Container() czy bez
              const SizedBox(
                height: 15,
              ),
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
              const SizedBox(
                height: 60,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
                child: MyTextField(
                    hintText: "Login",
                    obscureText: false,
                    keyboardType: TextInputType.emailAddress,
                    controller: loginController),
              ),
              // CheckboxListTile(
              //   value: isChecked,
              //   title: const Text("Custom Domain"),
              //   onChanged: (value) => onChanged(value!)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: MyTextField(
                    hintText: "Haslo",
                    obscureText: true,
                    keyboardType: TextInputType.visiblePassword,
                    controller: passwController),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, left: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ResetHasla()),
                        );
                      },
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
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: MyButton(
                  text: 'Zaloguj się',
                  onTap: () => auth.AuthService().login(
                    login: loginController.text,
                    password: passwController.text,
                  ),
                ),
              )
              //! jakbys mial ogromny problem to zamiast komponentu uzyj tego ponizej ale bedzie to zle wygladac
              // Container(
              //   padding: EdgeInsets.symmetric(horizontal: 12),
              //   height: 56, // Wysokość textfieldu
              //   child: ElevatedButton(
              //     onPressed: () {
              //       // Dodaj tu akcje po kliknięciu przycisku
              //     },
              //     style: ElevatedButton.styleFrom(
              //       minimumSize: Size.fromHeight(56),
              //       backgroundColor: Theme.of(context).colorScheme.secondary,
              //     ),
              //     child: Text(
              //       'Mój Przycisk',
              //       // style: TextStyle(
              //       //   color: Theme.of(context).colorScheme.onPrimary,
              //       // ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
