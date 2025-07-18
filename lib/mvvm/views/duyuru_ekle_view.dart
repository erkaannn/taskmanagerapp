import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:taskmanagmentapp/mvvm/views/duyuru_ekle_model.dart';
import 'package:taskmanagmentapp/mvvm/views/duyuru_goruntule_view.dart';

import 'admin_anasayfa.dart';

class DuyuruEkleView extends StatefulWidget {
  const DuyuruEkleView({super.key});

  @override
  State<DuyuruEkleView> createState() => _DuyuruEkleViewState();
}

class _DuyuruEkleViewState extends State<DuyuruEkleView> {
  TextEditingController duyuruBaslik = TextEditingController();
  TextEditingController duyuruIcerik = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    duyuruBaslik.dispose();
    duyuruIcerik.dispose();
    super.dispose();
  }

  void Message(String message, Color c) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: c));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DuyuruEkleModel>(
      create: (_) => DuyuruEkleModel(),
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => AdminAnasayfaView()),
                  (route) => false);
            },
          ),
          title: Text(
            "Duyuru Ekle",
            style: TextStyle(
              color: Colors.grey[800],
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 12),
                      TextFormField(
                        controller: duyuruBaslik,
                        decoration: InputDecoration(
                          labelText: 'Duyuru Başlığı',
                          prefixIcon: Icon(Icons.notification_add_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Duyuru Başlığı Giriniz';
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: duyuruIcerik,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Duyuru İçeriği',
                          prefixIcon: Icon(Icons.text_fields),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Duyuru İçeriği Giriniz';
                          } else {
                            return null;
                          }
                        },
                      ),
                      SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text("Duyuru Ekle"),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              await context
                                  .read<DuyuruEkleModel>()
                                  .addYeniDuyuru(
                                    duyuruBaslik: duyuruBaslik.text,
                                    duyuruIcerik: duyuruIcerik.text,
                                  )
                                  .then((value) =>
                                      Message("Duyuru Eklendi", Colors.green));
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.visibility_outlined),
                          label: Text("Duyuruları Görüntüle"),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DuyuruGoruntuleView()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
