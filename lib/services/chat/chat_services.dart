import 'package:chatify/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service that provides chat functionalities.
///
/// This service is responsible for handling one-on-one chat messaging,
/// including sending and receiving messages, and fetching the list of users.
class ChatServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns a stream of all users from the "Users" collection in Firestore.
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  /// Sends a message to a specific user.
  ///
  /// The message is stored in a chat room, which is identified by a unique
  /// ID generated from the current user's ID and the receiver's ID.
  Future<void> sendMessage(String reciverId, message) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderID: currentUserId,
      senderEmail: currentUserEmail,
      reciverID: reciverId,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, reciverId];
    ids.sort();
    String chatRoomID = ids.join('_');

    await _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());
  }

  /// Returns a stream of messages for a specific chat room.
  ///
  /// The chat room is identified by the unique ID generated from the two
  /// user IDs.
  Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }
}
