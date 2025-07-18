import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskmanagmentapp/mvvm/models/duyuru.dart';
import 'package:taskmanagmentapp/mvvm/services/database.dart';

class DuyuruGoruntuleViewModel extends ChangeNotifier {
  String _collectionPath = 'Duyurular';
  Database _database = Database();

  //stream list olustur
  Stream<List<Duyurular>> getDuyurular() {
    Stream<List<DocumentSnapshot>> streamListDocument = _database
        .getGorevApiAll(_collectionPath)
        .map((QuerySnapshot) => QuerySnapshot.docs);

    Stream<List<Duyurular>> streamListBook = streamListDocument.map(
        (listOfDocSnap) => listOfDocSnap
            .map((docSnap) => Duyurular.fromMap(docSnap.data()))
            .toList());

    return streamListBook;
  }
}
