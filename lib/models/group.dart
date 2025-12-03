import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  Group({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.createdByName,
    required this.memberIds,
    this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final String createdBy;
  final String? createdByName;
  final List<String> memberIds;
  final DateTime? createdAt;

  factory Group.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final Timestamp? timestamp = data['createdAt'] as Timestamp?;
    final members = (data['memberIds'] as List<dynamic>?)
            ?.whereType<String>()
            .toList(growable: false) ??
        <String>[];

    return Group(
      id: doc.id,
      name: (data['name'] as String?)?.trim() ?? 'Untitled group',
      description: (data['description'] as String?)?.trim() ?? '',
      createdBy: (data['createdBy'] as String?) ?? '',
      createdByName: (data['createdByName'] as String?)?.trim(),
      memberIds: members,
      createdAt: timestamp?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'memberIds': memberIds,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
