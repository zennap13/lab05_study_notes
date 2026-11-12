import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab05_study_notes/data/notes_repository.dart';
import 'package:lab05_study_notes/models/note.dart';

void main() {
  setUpAll(FakeFirebaseFirestore.new);

  test('Note.fromFirestore parses valid map properly', () {
    final note = Note.fromFirestore('test_id', {
      'title': 'Test Title',
      'body': 'Test Body',
      'createdAt': null,
    });

    expect(note.id, 'test_id');
    expect(note.title, 'Test Title');
    expect(note.body, 'Test Body');
  });

  test('NotesRepository throws ArgumentError when title is empty', () async {
    final firestore = FakeFirebaseFirestore();
    final repo = NotesRepository(firestore);

    expect(
      () => repo.addNote('u1', '   ', 'Valid body'),
      throwsA(isA<ArgumentError>()),
    );
  });
}
