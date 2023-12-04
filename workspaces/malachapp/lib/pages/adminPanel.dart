import 'package:flutter/material.dart';
import 'package:malachapp/auth/admin/admin.dart';
import 'package:malachapp/auth/auth_service.dart';
// import 'package:malachapp/components/herb.dart';
import 'package:malachapp/components/text_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:malachapp/components/my_button.dart';

class AdminPanel extends StatefulWidget {
  const AdminPanel({super.key});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  TextEditingController mail = TextEditingController();
  TextEditingController decipherController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded)),
                ],
              ),
            ),
            const SizedBox(
              height: 190,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Admin Panel",
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
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12, right: 12),
                    child: MyButton(
                      text: 'Wyślij',
                      onTap: () => AuthService().resetPassword(email: mail.text),
                    ),
                  ),
                  MyButton(text: 'STWORZ 10(na razie) UŻYTKOWNIKÓW (ADMIN_PANEL)', onTap: () => AuthCreateUser().createUsers()),
                  const SizedBox(height: 10),
                  MyTextField(hintText: 'email', controller: decipherController),
                  MyButton(text: 'Deszyfrowanie', onTap: () {
                    String result = AuthCreateUser().passwDecryption(decipherController.text);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Decryption Result'),
                          content: Text(result),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      }
                    );
                  }
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }
}

