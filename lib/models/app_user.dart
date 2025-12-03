import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    this.name,
  });

  final String uid;
  final String email;
  final String? name;

  String get displayName =>
      (name?.trim().isNotEmpty ?? false) ? name!.trim() : email;

  factory AppUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      uid: doc.id,
      email: (data['email'] as String?) ?? '',
      name: (data['name'] as String?)?.trim(),
    );
  }
}
