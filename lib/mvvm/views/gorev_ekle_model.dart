import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


import '../models/bireyselGorev.dart';
import '../services/database.dart';

class GorevEkleViewModel extends ChangeNotifier {
  Database _database = Database();
  String collectionPath = 'BireyselGorevler';
  String collectionPathKullanicilar = 'Kullanicilar';

  Future<void> addYeniGorev(
      {required String gorevBaslikbireysel,
      required String gorevIcerikbireysel,
      required String personelMail,
      required String sonTarih}) async {
    bireyselGorev yeniGorev = bireyselGorev(
      id: DateTime.now().toString(),
      sonTarih: sonTarih,
      gorevBaslikbireysel: gorevBaslikbireysel,
      gorevIcerikbireysel: gorevIcerikbireysel,
      personelMail: personelMail,
    );
    await _database.bireyselGorevEkle(
        collectionPath: collectionPath, bookAsMap: yeniGorev.toMap());
  }

  
}
