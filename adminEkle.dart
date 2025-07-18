import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase projen için gerekli options (bunları kendi projenin ayarlarından al)
import 'lib/firebase_options.dart'; // Bunu senin projen generate ediyor

Future<void> main() async {
  // Firebase'i başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  print("=== Admin Kullanıcı Ekleme ===");

  // Giriş bilgilerini al
  stdout.write("Email: ");
  String email = stdin.readLineSync()!;

  stdout.write("Şifre: ");
  String sifre = stdin.readLineSync()!;

  stdout.write("Ad: ");
  String ad = stdin.readLineSync()!;

  stdout.write("Soyad: ");
  String soyad = stdin.readLineSync()!;

  stdout.write("Görev: ");
  String gorev = stdin.readLineSync()!;

  stdout.write("Telefon: ");
  String tel = stdin.readLineSync()!;

  try {
    // Auth'da kullanıcıyı oluştur
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: sifre);

    String uid = userCredential.user!.uid;

    // Firestore'a kaydet
    await FirebaseFirestore.instance.collection('Kullanicilar').doc(email).set({
      'kullaniciID': uid,
      'email': email,
      'sifre': sifre, 
      'admin': true, 
      'Ad': ad,
      'Soyad': soyad,
      'Gorev': gorev,
      'Tel': tel,
    });

    print("Admin kullanıcı başarıyla eklendi.");
  } catch (e) {
    print("Hata oluştu: $e");
  }
}
