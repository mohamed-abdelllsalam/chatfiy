import 'dart:math';

import 'package:chatify/models/app_user.dart';
import 'package:chatify/models/group.dart';
import 'package:chatify/models/group_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupService {
  GroupService()
      : _firestore = FirebaseFirestore.instance,
        _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  CollectionReference<Map<String, dynamic>> get _groupsCollection =>
      _firestore.collection('groups');

  Stream<List<Group>> streamGroupsForCurrentUser() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const Stream<List<Group>>.empty();
    }

    return _groupsCollection
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final groups = snapshot.docs
          .map((doc) => Group.fromDocument(doc))
          .toList(growable: false);
      groups.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return groups;
    });
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required List<String> memberIds,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('A logged in user is required to create a group.');
    }

    final creatorProfile =
        await _firestore.collection('Users').doc(currentUser.uid).get();
    final creatorName = (creatorProfile.data()?['name'] as String?)?.trim() ??
        currentUser.email;

    final uniqueMembers = <String>{currentUser.uid, ...memberIds};

    final docRef = _groupsCollection.doc();

    await docRef.set({
      'name': name.trim(),
      'description': description.trim(),
      'createdBy': currentUser.uid,
      'createdByName': creatorName,
      'memberIds': uniqueMembers.toList(growable: false),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<AppUser>> fetchGroupMembers(List<String> memberIds) async {
    if (memberIds.isEmpty) {
      return const <AppUser>[];
    }

    const chunkSize = 10;
    final results = <AppUser>[];
    for (var i = 0; i < memberIds.length; i += chunkSize) {
      final chunk = memberIds.sublist(i, min(i + chunkSize, memberIds.length));
      final snapshot = await _firestore
          .collection('Users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      results.addAll(snapshot.docs.map(AppUser.fromDocument));
    }

    results.sort((a, b) => a.displayName.compareTo(b.displayName));
    return results;
  }

  Stream<Group?> streamGroupById(String groupId) {
    return _groupsCollection.doc(groupId).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return Group.fromDocument(doc);
    });
  }

  Stream<List<GroupMessage>> streamGroupMessages(String groupId) {
    return _groupsCollection
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroupMessage.fromDocument(groupId, doc))
            .toList(growable: false));
  }

  Future<void> sendGroupMessage({
    required String groupId,
    required String message,
  }) async {
    final trimmedMessage = message.trim();
    if (trimmedMessage.isEmpty) {
      return;
    }

    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw StateError('A logged in user is required to send messages.');
    }

    final senderProfile =
        await _firestore.collection('Users').doc(currentUser.uid).get();
    final senderName =
        (senderProfile.data()?['name'] as String?)?.trim() ?? currentUser.email;

    final newMessage = GroupMessage(
      id: '',
      groupId: groupId,
      senderId: currentUser.uid,
      senderEmail: currentUser.email ?? '',
      senderName: senderName,
      message: trimmedMessage,
      timestamp: DateTime.now(),
    );

    await _groupsCollection
        .doc(groupId)
        .collection('messages')
        .add(newMessage.toMap());
  }
}
