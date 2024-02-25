import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:malachapp/main.dart';
import 'package:malachapp/pages/notification_subs_page.dart';
import 'package:malachapp/services/notification_service.dart';
import 'package:malachapp/services/subscribe_to_noti.dart';

enum AuthStatus {
  successful,
  wrongPassword,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  firstLogin,
  unknown,
}

class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthStatus.wrongPassword;
        break;
      case "weak-password":
        status = AuthStatus.weakPassword;
        break;
      case "email-already-in-use":
        status = AuthStatus.emailAlreadyExists;
        break;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }
  static String generateErrorMessage(error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidEmail:
        errorMessage = "Your email address appears to be malformed.";
        break;
      case AuthStatus.weakPassword:
        errorMessage = "Your password should be at least 6 characters.";
        break;
      case AuthStatus.wrongPassword:
        errorMessage = "Your email or password is wrong.";
        break;
      case AuthStatus.emailAlreadyExists:
        errorMessage =
            "The email address is already in use by another account.";
        break;
      default:
        errorMessage = "An error occured. Please try again later.";
    }
    return errorMessage;
  }
}

class AuthService {
  final _auth = FirebaseAuth.instance;
  AuthStatus _status = AuthStatus.unknown;

  // Define a GlobalKey for NavigatorState
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<AuthStatus> login({
    required String login,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: login, password: password);
      bool isFirstLogin = _auth.currentUser?.metadata.creationTime == _auth.currentUser?.metadata.lastSignInTime; // Update this condition as per your logic

      if (isFirstLogin && navKey.currentContext != null) {
        SubscribeNotifications().subscribe('polls');
        SubscribeNotifications().subscribe('events');
        SubscribeNotifications().subscribe('posts');
        
        // Show a dialog
        await showDialog(
          context: navKey.currentContext!, // Use navigator key context
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Welcome!'),
              content: Text(
                'It seems like you are logging in from a new device. '
                'Would you like to set up your notification subscriptions?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(), // Close dialog
                  child: Text('Later'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Use navigatorKey to navigate
                    Navigator.of(context).pushNamed(
                      '/notifications'
                    );
                    
                  },
                  child: Text('Setup Subscriptions'),
                ),
              ],
            );
          },
        );
      }
      _status = AuthStatus.successful;
    } on FirebaseAuthException catch (e) {
      _status = AuthExceptionHandler.handleAuthException(e);
    }
    return _status;
  }
  // Działa, ale nie na kody recyklingowe
  Future<AuthStatus> resetPassword({required String email}) async {
    await _auth
        .sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful)
        .catchError((e) => _status = AuthExceptionHandler.handleAuthException(e));
    return _status;
  }

  Future<AuthStatus> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch(e) {
      _status = AuthExceptionHandler.handleAuthException(e);
    }
    return _status;
  }
}


class UserSettingsService {
  final _auth = FirebaseAuth.instance;

  Future<void> handleFirstLoginSubscriptions(BuildContext context) async {
    if (_auth.currentUser != null) {
      // Check if this is the first login from a new device
      if (_auth.currentUser!.metadata.creationTime ==
          _auth.currentUser!.metadata.lastSignInTime) {
        // Show a dialog to ask the user for subscriptions
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Welcome!'),
              content: Text(
                'It seems like you are logging in from a new device. '
                'Would you like to set up your notification subscriptions?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('Later'),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to the subscription page
                    Navigator.pushNamed(context, '/notifications');
                  },
                  child: Text('Setup Subscriptions'),
                ),
              ],
            );
          },
        );
      }
    }
  }
}

