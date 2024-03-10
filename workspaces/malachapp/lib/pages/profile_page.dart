import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/services/set_user.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

/// A page that displays the user's profile information.
class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _nickname = '';
  bool _gdprConfirmed = false;
  bool _vulgularConfirmation = false;
  String _newTitle = '';
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = auth.currentUser?.uid;
  }

  /// Updates the user's nickname.
  void _updateNickname(String newNickname) {
    setState(() {
      _nickname = newNickname;
    });
  }

  /// Toggles the GDPR confirmation status.
  void _toggleGdprConfirmation(bool value) {
    setState(() {
      _gdprConfirmed = value;
    });
  }

  /// Toggles the vulgular nickname confirmation status.
  void _toggleVulgularNicknameConfirmation(bool value) {
    setState(() {
      _vulgularConfirmation = value;
    });
  }

  /// Sets the title of the dialog based on the confirmation status.
  void _setTitle(String title) {
    _newTitle = title;
  }

  /// Builds the title widget for the dialog.
  Widget _buildTitle() {
    return Text(
      _newTitle.isNotEmpty ? _newTitle : 'Profile',
      style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    );
  }

  /// Saves the user's profile information.
  Future<void> _saveProfile() async {
    if (_gdprConfirmed && _vulgularConfirmation) {
      // Save the user's nickname and email to the collection
      // with the current user's email
      // Add your code here to save the data to the database

      // if(!(await setUser())) {
      //   _db.collection('users').doc(userId).update({
      //     'nickname': _nickname,
      //   });
      // } 
      await setUser().then((value) {
        if (value) {
          _db.collection('users').doc(userId).set({
            'nickname': _nickname,
          }, SetOptions(merge: true));
        } else {
          _db.collection('users').doc(userId).update({
            'nickname': _nickname,
          });
        }
      });
      print('Nickname: $_nickname');
      print('GDPR Confirmed: $_gdprConfirmed');
      print('Vulgular Confirmation: $_vulgularConfirmation');
    } else {
      String consequence = _gdprConfirmed ? 'vulgular' 
        : _vulgularConfirmation 
          ? 'GDPR' 
          : 'GDPR and vulgular';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // Add title variable
          if (!_gdprConfirmed && !_vulgularConfirmation) {
            _setTitle('GDPR and Vulgular Confirmation');
          } else if (!_gdprConfirmed) {
            _setTitle('GDPR Confirmation');
          } else {
            _setTitle('Vulgular Confirmation');
          }
          return AlertDialog(
            title: _buildTitle(),
            content: Text('Please confirm that you understand the $consequence consequences.'),
            actions: [
              TextButton(
                child: Text(
                  'OK',
                  style: Provider.of<ThemeProvider>(context).themeData == darkMode
                      ? const TextStyle(color: Colors.white)
                      : const TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change Nickname',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            TextField(
              onChanged: _updateNickname,
              decoration: const InputDecoration(
                hintText: 'Enter new nickname',
              ),
            ),
            const SizedBox(height: 16.0),
            CheckboxListTile(
              title: const Text('I understand the GDPR consequences'),
              value: _gdprConfirmed,
              onChanged: (bool? value) => _toggleGdprConfirmation(value ?? false),
            ),
            CheckboxListTile(
              title: const Text('I understand having the vulgular nickname consequences'),
              value: _vulgularConfirmation,
              onChanged: (bool? value) => _toggleVulgularNicknameConfirmation(value ?? false),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: SizedBox(
                width: 200, // Set the desired width here
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Provider.of<ThemeProvider>(context).themeData == darkMode
                        ? Colors.grey.shade800
                        : Colors.white,
                  ),
                  child: Text(
                    'Save Profile',
                    style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).themeData == darkMode
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}