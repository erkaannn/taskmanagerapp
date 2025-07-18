import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmanagmentapp/mvvm/models/bireyselGorev.dart';

import '../models/duyuru.dart';
import '../models/ekipGorev.dart';

class Database {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getGorevApiAll(String referencePath) {
    return firestore.collection(referencePath).snapshots();
  }

  Future<void> bireyselGorevEkle(
      {String? collectionPath, Map<String, dynamic>? bookAsMap}) async {
    await firestore
        .collection(collectionPath!)
        .doc(bireyselGorev.fromMap(bookAsMap!).id)
        .set(bookAsMap);
  }

  Stream<QuerySnapshot> getEkipGorevApiAll(String referencePath) {
    return firestore.collection(referencePath).snapshots();
  }
  Future<void> ekipgorevEkle(
      {String? collectionPath, Map<String, dynamic>? ekipAsMap}) async {
    await firestore
        .collection(collectionPath!)
        .doc(EkipGorev.fromMap(ekipAsMap!).id)
        .set(ekipAsMap);
  }
  Future<void> duyuruEkle({String? collectionPath, Map<String, dynamic>? ekipAsMap}) async {
    await firestore
        .collection(collectionPath!)
        .doc(Duyurular.fromMap(ekipAsMap!).id)
        .set(ekipAsMap);
  }
}
