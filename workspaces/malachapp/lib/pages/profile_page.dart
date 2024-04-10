import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/services/nickname_fetcher.dart';
import 'package:malachapp/services/set_user.dart';
import 'package:malachapp/themes/dark_mode.dart';
import 'package:malachapp/themes/theme_provider.dart';
import 'package:provider/provider.dart';

/// A page that displays the user's profile information.
class ProfilePageSettings extends StatefulWidget {
  @override
  _ProfilePageSettingsState createState() => _ProfilePageSettingsState();
}

class _ProfilePageSettingsState extends State<ProfilePageSettings> {
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
      _newTitle.isNotEmpty ? _newTitle : 'Profil',
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
      }).then((value) => Navigator.of(context).pop());
      print('Nickname: $_nickname');
      print('RODO Confirmed: $_gdprConfirmed');
      print('Vulgular Confirmation: $_vulgularConfirmation');
    } else {
      String consequence = _gdprConfirmed ? 'konsekwencje wulgarnych pseudonimów' 
        : _vulgularConfirmation 
          ? 'RODO' 
          : 'RODO i konsekwencje wulgarnych pseudonimów';
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // Add title variable
          if (!_gdprConfirmed && !_vulgularConfirmation) {
            _setTitle('Potwierdzenie GDPR i wulgarnych');
          } else if (!_gdprConfirmed) {
            _setTitle('Potwierdzenie GDPR');
          } else {
            _setTitle('Potwierdzenie wulgarnych pseudonimów');
          }
          return AlertDialog(
            title: _buildTitle(),
            content: Text('Potwierdź, że rozumiesz $consequence.'),
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
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Zmień pseudonim',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
                TextField(
                  onChanged: _updateNickname,
                  decoration: const InputDecoration(
                    hintText: 'Wprowadź nowy pseudonim',
                  ),
                ),
            const SizedBox(height: 16.0),
            CheckboxListTile(
              title: const Text('Rozumiem RODO'),
              value: _gdprConfirmed,
              onChanged: (bool? value) => _toggleGdprConfirmation(value ?? false),
            ),
            CheckboxListTile(
              title: const Text('Rozumiem konsekwencje posiadania wulgarnego pseudonimu'),
              value: _vulgularConfirmation,
              onChanged: (bool? value) => _toggleVulgularNicknameConfirmation(value ?? false),
            ),
            const SizedBox(height: 16.0),
            Center(
              child: Row(
                children: [
                  SizedBox(
                    width: 200, // Set the desired width here
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Provider.of<ThemeProvider>(context).themeData == darkMode
                            ? Colors.grey.shade800
                            : Colors.white,
                      ),
                      child: Text(
                        'Zapisz profil',
                        style: TextStyle(
                          color: Provider.of<ThemeProvider>(context).themeData == darkMode
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
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


class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<String> fetchNickname () {
    String? userId = auth.currentUser?.uid;
    return _db.collection('users').doc(userId).snapshots()
      .map((snapshot) => snapshot.data()?['nickname'] as String? ?? '');
  }

  Stream<String> fetchClass() {
    String? userId = auth.currentUser?.uid;
    return _db.collection('users').doc(userId).snapshots()
      .map((snapshot) => snapshot.data()?['class'] as String? ?? '');
  }

  Widget _buildCancelButton() {
  return Visibility(
    visible: NicknameFetcher().fetchNickname(auth.currentUser!.uid) != '',
      child: IconButton(
        onPressed: () async {
          await setUser().then((value) {
            if (value) {
              _db.collection('users').doc(auth.currentUser?.uid).set({
                'nickname': '',
              }, SetOptions(merge: true));
            } else {
              _db.collection('users').doc(auth.currentUser?.uid).update({
                'nickname': '',
              });
            }
           });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Provider.of<ThemeProvider>(context).themeData == darkMode
              ? Colors.grey.shade800
              : Colors.white,
        ),
        icon: Icon(
          Icons.delete,
          color: Provider.of<ThemeProvider>(context).themeData == darkMode
            ? Colors.red[400]
            : Colors.red[700],
          size: 25,
        ),
      ),
    );
  }

  Widget buildListTileNickname(BuildContext context) {
    return StreamBuilder(
      stream: fetchNickname(),
      builder:
          (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Pseudonim: (wczytywanie)'),
            leading: Icon(Icons.person),
          );
        }
        if (snapshot.hasError) {
          return ListTile(
            title: Text('Błąd: ${snapshot.error}'),
            leading: const Icon(Icons.error),
          );
        }
        if (snapshot.data == '') {
          return ListTile(
            title: const Text('Pseudonim: (nie ustawiony)'),
            leading: const Icon(Icons.person),
            trailing: const Icon(Icons.edit),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ProfilePageSettings(),
              ),
            )
          );
        }
        return ListTile(
          title: Row(
            children: [
              Text('Pseudonim: ${snapshot.data}'),
            ],
          ),
          leading: const Icon(Icons.person),
          trailing: _buildCancelButton(),
        );
      },
    );
  }

  Future<void> _setClassDropdown() async {
    String classValue = 'A'; // Initial class value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wybierz klasę'),
          content: StatefulBuilder( // Use StatefulBuilder to update the state inside the dialog
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value: classValue, // Set the initial value
                onChanged: (String? newValue) {
                  setState(() { // Use the StateSetter to update the dropdown's state
                    classValue = newValue!;
                  });
                },
                items: <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value, // Correct value assignment
                    child: Text(
                      value,
                      style: Provider.of<ThemeProvider>(context).themeData == darkMode
                          ? const TextStyle(color: Colors.white)
                          : const TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Anuluj', style: TextStyle(color: Theme.of(context).textTheme.labelLarge?.color)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Zapisz', style: TextStyle(color: Theme.of(context).textTheme.labelLarge?.color)),
              onPressed: () {
                _db.collection('users').doc(auth.currentUser?.uid).set({
                  'class': classValue,
                }, SetOptions(merge: true));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _setYearDropdown() {
    String yearValue = '2024/2025'; // Assuming '1' is a valid initial value

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Wybierz rok'),
          content: FutureBuilder<DocumentSnapshot>(
            future: _db.collection('academicYears').doc('exT9bo4N0RNOPXHTDxFL').get(), // Fetching the data
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator(); // Show loading indicator while waiting for data
              } else if (snapshot.hasError) {
                return Text('Błąd: ${snapshot.error}'); // Error handling
              } else if (snapshot.hasData && snapshot.data!.data() != null) {
                // Once data is fetched, use StatefulBuilder to allow for updating the dropdown's state
                List<String> years = List<String>.from((snapshot.data!.data() as Map<String, dynamic>)['years']);
                return StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return DropdownButton<String>(
                      value: yearValue, // Set the initial value
                      onChanged: (String? newValue) {
                        setState(() { // Update the dropdown's state
                          yearValue = newValue!;
                        });
                      },
                      items: years.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value, // Correct value assignment
                          child: Text(
                            value,
                            style: Provider.of<ThemeProvider>(context).themeData == darkMode
                                ? const TextStyle(color: Colors.white)
                                : const TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              } else {
                return const Text('Brak dostępnych lat'); // Handle the case where no data is available
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Anuluj', style: TextStyle(color: Theme.of(context).textTheme.labelLarge?.color)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Zapisz', style: TextStyle(color: Theme.of(context).textTheme.labelLarge?.color)),
              onPressed: () {
                // Assuming `_db` and `auth.currentUser?.uid` are correctly defined and available
                _db.collection('users').doc(auth.currentUser?.uid).set({
                  'year': yearValue,
                }, SetOptions(merge: true));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildListTileClass(BuildContext context) {
    return StreamBuilder(
      stream: fetchClass(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Klasa: (wczytywanie)'),
            leading: Icon(Icons.school),
          );
        }
        if (snapshot.hasError) {
          return ListTile(
            title: Text('Błąd: ${snapshot.error}'),
            leading: const Icon(Icons.error),
          );
        }
        if (snapshot.data == '') {
            return ListTile(
            title: const Text('Klasa: (nie ustawiona)'),
            leading: const Icon(Icons.school),
            trailing: const Icon(Icons.edit),
            onTap: () {
              _setClassDropdown();
            },
          );
        }
        return ListTile(
          title: Text('Klasa: ${snapshot.data}'),
          leading: const Icon(Icons.school),
          trailing: const Icon(Icons.edit),
          onTap: () async {
            await _setClassDropdown();
          },
        );
      },
    );
  }
  Stream<String> fetchYear() {
    String? userId = auth.currentUser?.uid;
    return _db.collection('users').doc(userId).snapshots()
      .map((snapshot) => snapshot.data()?['year'] as String? ?? '');
  }

  Widget _buildListTileYear(BuildContext context) {
    return StreamBuilder(
      stream: fetchYear(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Rok: (wczytywanie)'),
            leading: Icon(Icons.school),
          );
        }
        if (snapshot.hasError) {
          return ListTile(
            title: Text('Błąd: ${snapshot.error}'),
            leading: const Icon(Icons.error),
          );
        }
        if (snapshot.data == '') {
            return ListTile(
            title: const Text('Rok: (nie ustawiony)'),
            leading: const Icon(Icons.school),
            trailing: const Icon(Icons.edit),
            onTap: () {
              _setYearDropdown();
            },
          );
        }
        return ListTile(
          title: Text('Rok: ${snapshot.data}'),
          leading: const Icon(Icons.school),
          trailing: const Icon(Icons.edit),
          onTap: () {
            _setYearDropdown();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String email = auth.currentUser?.email ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Center(
        child: Column(
          children: [
            Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  buildListTileNickname(context),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text('Email: $email'),
                  ),
                  _buildListTileClass(context),
                  _buildListTileYear(context),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Ustawienia'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfilePageSettings(),
                        ),
                      );
                    },
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