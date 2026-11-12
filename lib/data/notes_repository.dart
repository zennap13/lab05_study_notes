import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/note.dart';

class NotesRepository {
  final FirebaseFirestore _firestore;

  NotesRepository([FirebaseFirestore? firestore])
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<Note>> watchNotes(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Note.fromFirestore(doc.id, doc.data()))
              .toList();
        });
  }

  Future<void> addNote(String uid, String title, String body) async {
    final trimmedTitle = title.trim();
    final trimmedBody = body.trim();

    if (trimmedTitle.isEmpty || trimmedTitle.length > 100) {
      throw ArgumentError('Title must be between 1 and 100 characters');
    }

    await _firestore.collection('users').doc(uid).collection('notes').add({
      'title': trimmedTitle,
      'body': trimmedBody,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteNote(String uid, String noteId) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .delete();
  }
}
