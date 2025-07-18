import 'package:cloud_firestore/cloud_firestore.dart';

class EkipGorev {
  final String id;
  final String gorevBaslikEkip;
  final String gorevIcerikEkip;
  final List personelMail;
  final String sonTarih;

  EkipGorev(
      {required this.id,
      required this.gorevBaslikEkip,
      required this.gorevIcerikEkip,
      required this.personelMail,
      required this.sonTarih});

  Map<String, dynamic> toMap() => {
        'id': id,
        'gorevBaslikEkip': gorevBaslikEkip,
        'gorevIcerikEkip': gorevIcerikEkip,
        'personelMail': personelMail,
        'sonTarih': sonTarih,
      };

  factory EkipGorev.fromMap(map) => EkipGorev(
        id: map['id'],
        gorevBaslikEkip: map['gorevBaslikEkip'],
        gorevIcerikEkip: map['gorevIcerikEkip'],
        personelMail: map['personelMail'],
        sonTarih: map['sonTarih'],
      );
}
