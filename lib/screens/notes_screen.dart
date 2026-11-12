import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  void _setupFCM() {
    // Sayfa açıldığında bildirimi ekranda gösterir
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    });

    // Firebase bildirim dinleyicisi
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${message.notification!.title}: ${message.notification!.body}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.deepPurple,
            duration: const Duration(seconds: 20),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Note'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final activeUid =
                  widget.uid ?? FirebaseAuth.instance.currentUser?.uid;
              if (activeUid != null && _titleController.text.isNotEmpty) {
                await FirebaseFirestore.instance.collection('notes').add({
                  'title': _titleController.text,
                  'content': _contentController.text,
                  'userId': activeUid,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                _titleController.clear();
                _contentController.clear();
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeUid = widget.uid ?? FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: activeUid == null
          ? const Center(child: Text('Not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('notes')
                  .where('userId', isEqualTo: activeUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No notes yet'));
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(data['title'] ?? ''),
                        subtitle: Text(data['content'] ?? ''),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
