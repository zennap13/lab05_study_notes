# ADR-001: Implementing Firestore Data Modeling and UI State Management with AI Assistance

## Status
Accepted

## Context
In Lab 5, we need to securely store user-specific notes in Cloud Firestore, reactively update the UI on data changes, and enforce Firestore security rules so that users cannot access other users' data. I consulted an AI assistant to explore the best structure for mapping Firestore documents and managing reactive state without adding heavy third-party packages.

## Prompt / Query Given to AI
"How should I structure the Note model fromFirestore factory and the NotesRepository watchNotes stream in Flutter to listen to user-specific subcollections efficiently, handle missing/invalid types, and keep tests passing with fake_cloud_firestore?"

## AI Proposal
The assistant suggested:
1. Validating `title` and `body` directly inside `Note.fromFirestore` using a type check and throwing `FormatException` if invalid, rather than letting null values crash the app later.
2. Placing notes under `users/{uid}/notes/{noteId}` so that authorization in `firestore.rules` can be validated simply via `request.auth.uid == userId`.
3. Using a `StreamBuilder` combined with `collection(...).snapshots()` rather than manual state management or polling.

## Decision & Reflection
I accepted this approach because:
- Storing notes in a user-scoped subcollection makes security rules strictly isolated and matches the lab specification.
- Throwing `FormatException` meets the explicit test requirements for malformed Firestore documents.
- `StreamBuilder` keeps the UI cleanly synced with Firestore live updates with minimal boilerplate.

## Consequences
- Data is strictly partitioned per user ID.
- Adding notes requires valid fields and adheres to the 1-100 character restriction.
- Testing is straightforward using `fake_cloud_firestore` in `test/own_test.dart`.