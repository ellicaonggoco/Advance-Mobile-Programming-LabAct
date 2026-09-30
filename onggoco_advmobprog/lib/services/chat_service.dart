import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Kunin lahat ng registered users mula sa Firestore Users collection
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = Map<String, dynamic>.from(doc.data());
        user['uid'] = (user['uid'] ?? doc.id).toString();
        return user;
      }).toList();
    });
  }

  // Magpadala ng mensahe sa chat room
  Future<void> sendMessage(String receiverId, String message) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return;

    final String currentUserId = currentUser.uid;
    final String currentUserEmail = currentUser.email ?? "";
    final Timestamp timestamp = Timestamp.now();

    MessageModel newMessage = MessageModel(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Gawa ng unique chatRoomID sa pamamagitan ng pag-sort ng UIDs
    // Hal: [userA, userB] sorted -> userA_userB
    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomID = ids.join('_');

    // I-save ang mensahe sa collection ng specific chat room
    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  // Real-time stream ng messages sa pagitan ng dalawang users
  Stream<QuerySnapshot> getMessage(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Helper para hanapin ang UID gamit ang Email
  Future<String?> getUidByEmail(String email) async {
    final q = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return (q.docs.first.data()['uid'] ?? '').toString();
  }

  // Helper para ma-save ang user document sa 'Users' collection pag nag-login o sign up
  Future<void> saveUserRecord({
    required String uid,
    required String email,
    String? firstName,
  }) async {
    await _firestore.collection("Users").doc(uid).set({
      'uid': uid,
      'email': email,
      'firstName': (firstName != null && firstName.isNotEmpty)
          ? firstName
          : email.split('@').first,
    }, SetOptions(merge: true));
  }
}
