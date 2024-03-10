import 'package:uuid/uuid.dart' show Uuid; // Import the uuid package
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:malachapp/auth/auth_service.dart';

class GroupService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to create a group (Admin only)
  Future<void> createGroup(String groupName, List<String> membersEmails, String adminEmail) async {
    // Check if creator is an Admin
    final isAdmin = await AuthService().isAdmin(FirebaseAuth.instance.currentUser!);
    if (!isAdmin) {
      throw Exception('Only admins can create groups.');
    }

    // Create group document
    DocumentReference groupRef = await _db.collection('groups').add({
      'name': groupName,
      'admin': adminEmail,
      'members': membersEmails,
    });

    // Add initial message or any setup needed
  }

  // Function to send a message to a group
  Future<void> sendMessage(String groupId, String message, String userEmail) async {
    await _db.collection('groups').doc(groupId).collection('messages').add({
      'text': message,
      'sender': userEmail,
      'sendersNickname': await _db
                          .collection('users')
                          .doc(_auth.currentUser!.uid)
                          .get()
                          .then((value) => value.data()!['nickname']) as String,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

class Group {
  String? id;
  String? name;
  List<String>? members; // Store member user IDs or emails
  String? admin; // Admin user ID

  Group({this.id, this.name, this.members, this.admin});

  // Convert a Group into a Map. The keys must correspond to the names of the
  // fields in your Firestore collection.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'admin': admin,
    };
  }

  // A method to create a Group object from a map (Firestore document)
  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      members: List<String>.from(map['members']),
      admin: map['admin'],
    );
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createGroup(String groupName, String adminEmail) async {
    var currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.email == adminEmail) {
      // Assuming the admin status is verified
      var groupId = const Uuid().v4(); // Generate unique ID for the group
      var newGroup = Group(
        id: groupId,
        name: groupName,
        members: [currentUser.uid], // Initially add the admin as member
        admin: currentUser.uid,
      );

      // Save the new group to Firestore
      await _db
          .collection('groups')
          .doc(groupId)
          .set(newGroup.toMap());
    } else {
      print("Only admins can create groups.");
    }
  }

  Future<void> addMemberToGroup(String groupId, String userEmail) async {
    var userDoc = await _db
        .collection('users')
        .where('email', isEqualTo: userEmail)
        .get();
    if (userDoc.docs.isNotEmpty) {
      var userId = userDoc.docs.first.id;
      // Fetch the group document
      var groupDoc = await _db.collection('groups').doc(groupId).get();
      if (groupDoc.exists) {
        Group group = Group.fromMap(groupDoc.data()!); // Add '!' to handle possible null value
        if (!group.members!.contains(userId)) {
          group.members?.add(userId);
          // Update the group document with the new member list
          await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
            'members': group.members,
          });
        } else {
          print("User already in the group.");
        }
      } else {
        print("Group does not exist.");
      }
    } else {
      print("User does not exist.");
    }
  }
  

}

