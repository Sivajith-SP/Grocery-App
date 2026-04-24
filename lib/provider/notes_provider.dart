import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:grocery_app/models/notes_model.dart';

class NotesProvider extends ChangeNotifier{
  List<Notes> notes=[];

  final FirestoreService _service =FirestoreService();

  Future<void> addNote(String title) async{
    Notes note = Notes(title: title);
    await _service.addNote(note);
    await fetchNotes();
  }

  Future<void> fetchNotes() async{
    notes = await _service.getNotes();
    notifyListeners();
  }
}

class FirestoreService{
  final  FirebaseFirestore _db =FirebaseFirestore.instance;
  Future<void> addNote(Notes note) async{
    await _db.collection('notes').add(note.toMap());
  }

  Future<List<Notes>> getNotes() async{
    var snapshot =  await _db.collection('notes').get();
    return snapshot.docs
        .map((doc)=>Notes.fromFirestore(doc.data()))
        .toList();

  }
}