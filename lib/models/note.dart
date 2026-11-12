import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String body;
  final DateTime? createdAt;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    this.createdAt,
  });

  factory Note.fromFirestore(String id, Map<String, dynamic> data) {
    final title = data['title'];
    final body = data['body'];

    if (title is! String || body is! String) {
      throw const FormatException('Title and body must be strings');
    }

    DateTime? createdAt;
    final timestamp = data['createdAt'];
    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    }

    return Note(id: id, title: title, body: body, createdAt: createdAt);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'body': body,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
