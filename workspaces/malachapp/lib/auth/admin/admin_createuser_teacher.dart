
  import 'package:firebase_admin/firebase_admin.dart';
  import 'package:logging/logging.dart';

  final Logger logger = Logger('AdminCreateUserTeacher');

  final admin = FirebaseAdmin.instance.initializeApp();

  Future<void> createUser(String nameInRoman, String surnameInRoman) async {
    try {
      final userRecord = await admin.auth().createUser(
        email: '$nameInRoman.$surnameInRoman@malachowianka.edu.pl',
        password: '$nameInRoman.$surnameInRoman',
      );
      logger.info('User created: ${userRecord.uid}');
    } catch (e) {
      logger.severe('Error creating user: $e');
    }
  }
