/*
  Ludzie beda dostawali token weryfikacyjny aby grupować chujkow do klasy.
  Login to nazwa emailu
  Wzór: login@malach.com
  Passw: Cezar z loginu o przesunieciu +1789
*/


import 'package:flutter/material.dart';
import 'package:malachapp/auth/auth_service.dart' as auth;
import 'package:malachapp/components/text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwController = TextEditingController();
  final auth.AuthService _authService = auth.AuthService();
  auth.AuthStatus _loginStatus = auth.AuthStatus.unknown;

  Future<void> performLogin() async {
  try {
    _loginStatus = await _authService.login(
      login: loginController.text,
      password: passwController.text,
    );
  } on auth.AuthExceptionHandler catch (e) {
    print(e);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle,
              size: 150,
            ),
            const Text(
              "Logowanie",
            ),
            const SizedBox(height: 100),
            MyTextField(
                hintText: "", obscureText: false, controller: loginController),
            const SizedBox(height: 10),
            MyTextField(
                hintText: "haslo",
                obscureText: false,
                controller: passwController),
            ElevatedButton(
              onPressed: () => performLogin(),
              child: const Text('Login'),
            )
          ],
        ),
      ),
    );
  }
}
