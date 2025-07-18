import 'package:cloud_firestore/cloud_firestore.dart';

class bireyselGorev {
  final String id;

  final String gorevBaslikbireysel;
  final String gorevIcerikbireysel;
  final String personelMail;
  final String sonTarih;

  bireyselGorev(
      {required this.id,
      required this.gorevBaslikbireysel,
      required this.gorevIcerikbireysel,
      required this.personelMail,
      required this.sonTarih});

  Map<String, dynamic> toMap() => {
        'id': id,
        'gorevBaslikbireysel': gorevBaslikbireysel,
        'gorevIcerikbireysel': gorevIcerikbireysel,
        'personelMail': personelMail,
        'sonTarih': sonTarih,
      };

  factory bireyselGorev.fromMap(map) => bireyselGorev(
        id: map['id'],
        gorevBaslikbireysel: map['gorevBaslikbireysel'],
        gorevIcerikbireysel: map['gorevIcerikbireysel'],
        personelMail: map['personelMail'],
        sonTarih: map['sonTarih'],
      );
}

