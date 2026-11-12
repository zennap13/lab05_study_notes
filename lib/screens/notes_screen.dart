import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/notes_repository.dart';
import '../data/auth_repository.dart';
import '../models/note.dart';

class NotesScreen extends StatefulWidget {
  final String? uid;
  const NotesScreen({super.key, this.uid});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupFCM();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _setupFCM() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Lab 05 Test: FCM test message',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.deepPurple,
            duration: Duration(seconds: 30),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    try {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${message.notification!.title}: ${message.notification!.body}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.deepPurple,
              duration: const Duration(seconds: 20),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } catch (_) {}
  }

  void _showAddNoteDialog(
    BuildContext context,
    NotesRepository? repo,
    String uid,
  ) {
    _titleController.clear();
    _contentController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('New note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Body'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final title = _titleController.text.trim();
                final body = _contentController.text.trim();

                if (title.isNotEmpty) {
                  Navigator.pop(dialogContext);
                  if (repo != null) {
                    await repo.addNote(uid, title, body);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AuthRepository? authRepo;
    NotesRepository? notesRepo;

    try {
      authRepo = Provider.of<AuthRepository?>(context);
    } catch (_) {}

    try {
      notesRepo = Provider.of<NotesRepository?>(context);
    } catch (_) {}

    final activeUid = widget.uid ?? authRepo?.currentUser?.uid ?? 'u1';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              if (authRepo != null) {
                await authRepo.signOut();
              }
            },
          ),
        ],
      ),
      body: notesRepo == null
          ? const Center(child: Text('No notes yet'))
          : StreamBuilder<List<Note>>(
              stream: notesRepo.watchNotes(activeUid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final notes = snapshot.data ?? [];
                if (notes.isEmpty) {
                  return const Center(child: Text('No notes yet'));
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      title: Text(note.title),
                      subtitle: note.body.isNotEmpty ? Text(note.body) : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            notesRepo?.deleteNote(activeUid, note.id),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add note',
        onPressed: () => _showAddNoteDialog(context, notesRepo, activeUid),
        child: const Icon(Icons.add),
      ),
    );
  }
}
