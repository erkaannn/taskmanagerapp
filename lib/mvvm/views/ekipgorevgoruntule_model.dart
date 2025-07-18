import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


import '../models/ekipGorev.dart';
import '../services/database.dart';

class EkipGorevGoruntuleViewModel extends ChangeNotifier {
  List<EkipGorev> ekipGorevler = [];

  String _collectionPath = 'EkipGorevler';

  Database _database = Database();

  Stream<List<EkipGorev>> getEkipGorevler() {
    Stream<List<DocumentSnapshot>> streamListDocument = _database
        .getGorevApiAll(_collectionPath)
        .map((QuerySnapshot) => QuerySnapshot.docs);

    Stream<List<EkipGorev>> streamListBook = streamListDocument.map(
        (listOfDocSnap) => listOfDocSnap
            .map((docSnap) => EkipGorev.fromMap(docSnap.data()))
            .toList());

    return streamListBook;
  }

  Future<void> addYeniGorev(
      {required String gorevBaslikEkip,
      required String gorevIcerikEkip,
      required List personelMail,
      required String sonTarih}) async {
    EkipGorev yeniGorev = EkipGorev(
      id: DateTime.now().toString(),
      sonTarih: sonTarih,
      gorevBaslikEkip: gorevBaslikEkip,
      gorevIcerikEkip: gorevIcerikEkip,
      personelMail: personelMail,
    );
    await _database.ekipgorevEkle(
        collectionPath: _collectionPath,ekipAsMap : yeniGorev.toMap());
  }

  //Future<void> deleteBook(EkipGorev book) async {
   // await _database.deleteDocument(referecePath: _collectionPath, id: book.id);
  //}
}
