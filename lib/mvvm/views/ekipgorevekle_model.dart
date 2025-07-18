import 'package:flutter/material.dart';

import '../models/ekipGorev.dart';
import '../services/database.dart';

class EkipGorevEkleModel extends ChangeNotifier {
  Database _database = Database();
  String collectionPath = 'EkipGorevler';

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
        collectionPath: collectionPath, ekipAsMap: yeniGorev.toMap());
  }
}