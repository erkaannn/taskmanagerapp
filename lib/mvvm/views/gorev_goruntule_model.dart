import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/bireyselGorev.dart';
import '../services/database.dart';

class GorevGoruntuleViewModel extends ChangeNotifier {
  List<bireyselGorev> bireyselGorevler = [];

  String _collectionPath = 'BireyselGorevler';

  Database _database = Database();

  Stream<List<bireyselGorev>> getBireyselGorevler() {
    Stream<List<DocumentSnapshot>> streamListDocument = _database
        .getGorevApiAll(_collectionPath)
        .map((QuerySnapshot) => QuerySnapshot.docs);

    Stream<List<bireyselGorev>> streamListBook = streamListDocument.map(
        (listOfDocSnap) => listOfDocSnap
            .map((docSnap) => bireyselGorev.fromMap(docSnap.data()))
            .toList());

    return streamListBook;
  }


}
