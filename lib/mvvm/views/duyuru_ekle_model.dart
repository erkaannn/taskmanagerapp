import 'package:flutter/material.dart';

import '../models/duyuru.dart';
import '../services/database.dart';

class DuyuruEkleModel extends ChangeNotifier {
  String collectionPath = 'Duyurular';
  Database _database = Database();
  Future<void> addYeniDuyuru(
      {required String duyuruBaslik,
      required String duyuruIcerik,
     }) async {
    Duyurular yeniDuyuru = Duyurular(
      id: DateTime.now().toString(),
      duyuruBaslik: duyuruBaslik,
      duyuruIcerik: duyuruIcerik,
    );
    await _database.duyuruEkle(
        collectionPath: collectionPath, ekipAsMap: yeniDuyuru.toMap());
  }
}
