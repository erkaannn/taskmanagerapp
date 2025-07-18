class Duyurular {
  final String id;
  final String duyuruBaslik;
  final String duyuruIcerik;

  Duyurular(
      {required this.id,
      required this.duyuruBaslik,
      required this.duyuruIcerik});

  Map<String, dynamic> toMap() => {
        'id': id,
        'duyuruBaslik': duyuruBaslik,
        'duyuruIcerik': duyuruIcerik,
      };

  factory Duyurular.fromMap(map) => Duyurular(
        id: map['id'],
        duyuruBaslik: map['duyuruBaslik'],
        duyuruIcerik: map['duyuruIcerik'],
      );

      
}
