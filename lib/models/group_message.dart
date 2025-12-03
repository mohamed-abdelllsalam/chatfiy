import 'package:cloud_firestore/cloud_firestore.dart';

class GroupMessage {
  const GroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderEmail,
    required this.message,
    this.senderName,
    this.timestamp,
  });

  final String id;
  final String groupId;
  final String senderId;
  final String senderEmail;
  final String message;
  final String? senderName;
  final DateTime? timestamp;

  factory GroupMessage.fromDocument(
    String groupId,
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final Timestamp? ts = data['timestamp'] as Timestamp?;

    return GroupMessage(
      id: doc.id,
      groupId: groupId,
      senderId: (data['senderId'] as String?) ?? '',
      senderEmail: (data['senderEmail'] as String?) ?? '',
      senderName: (data['senderName'] as String?)?.trim(),
      message: (data['message'] as String?) ?? '',
      timestamp: ts?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'senderName': senderName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
