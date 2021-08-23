import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:notesapp/models/note_model.dart';
import 'package:notesapp/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class NoteProvider with ChangeNotifier {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  List<Note> _items = [];

  List<Note> get getItems {
    return [..._items];
  }

  bool isFavorite(String? id) {
    return _items.firstWhere((element) => element.id == id).isFav!;
  }

  Future<void> fetchNotes() async {
    try {
      QuerySnapshot<Map<String, dynamic>> value = await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notes')
          .get();
      value.docs.forEach((element) {
        _items.add(Note(
            content: element.data()['content'],
            date: element.data()['date'].toDate(),
            id: element.data()['id'],
            isFav: element.data()['isFav'],
            title: element.data()['title']));
      });
      notifyListeners();
    } catch (error) {
      print('error fetching');
    }
  }

  Future<void> createNote(Note note) async {
    String noteId = Uuid().v1();
    try {
      await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notes')
          .doc(noteId)
          .set({
        'id': noteId,
        'title': note.title,
        'content': note.content,
        'date': note.date,
        'isFav': note.isFav
      });
      print('added successfully');
      _items.add(Note(
          content: note.content,
          date: note.date,
          id: noteId,
          isFav: note.isFav,
          title: note.title));
      notifyListeners();
    } catch (error) {
      print('error creating new note');
    }
  }

  Future<void> editNote(Note note) async {
    try {
      await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notes')
          .doc(note.id)
          .update({
        'id': note.id,
        'title': note.title,
        'content': note.content,
        'date': note.date,
        'isFav': note.isFav
      });
      final noteIndex = _items.indexWhere((element) => element.id == note.id);
      _items[noteIndex] = note;
      print('edited successfully');
      notifyListeners();
    } catch (error) {
      print('error editing note');
    }
  }

  Future<void> toggleFavorite(Note note) async {
    try {
      print(note.isFav);
      bool newFav = !note.isFav!;
      print(newFav);
      await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notes')
          .doc(note.id)
          .update({'isFav': newFav});
      print('favorited changed successfully');
      final noteIndex = _items.indexWhere((element) => element.id == note.id);
      note.isFav = newFav;
      _items[noteIndex] = note;
      notifyListeners();
    } catch (error) {
      print('error editing note');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await users
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('notes')
          .doc(id)
          .delete();
      print('deleted');
      _items.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (error) {
      print('error');
    }
  }

  void deleteState() {
    _items.clear();
    notifyListeners();
  }
}
