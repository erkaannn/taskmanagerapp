import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'admin_anasayfa.dart';
import 'gorev_ekle_model.dart';

class GorevEkleView extends StatefulWidget {
  const GorevEkleView({super.key});

  @override
  State<GorevEkleView> createState() => _GorevEkleViewState();
}

class _GorevEkleViewState extends State<GorevEkleView> {
  DateTime selectedDate = DateTime.now();
  var selectFormat = '';
  var formatter = DateFormat('dd/MM/yyyy');
  ScrollController _modalScrollController = ScrollController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectFormat = DateFormat('dd/MM/yyyy').format(selectedDate);
        gorevTarih.text = selectFormat;
      });
    }
  }

  String secilenMail = "";

  TextEditingController gorevBaslik = TextEditingController();
  TextEditingController gorevIcerik = TextEditingController();
  TextEditingController gorevTarih = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Message(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green));
  }

  @override
  void dispose() {
    gorevBaslik.dispose();
    gorevIcerik.dispose();
    gorevTarih.dispose();
    _modalScrollController.dispose();
    secilenMail = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GorevEkleViewModel>(
      create: (_) => GorevEkleViewModel(),
      builder: (context, _) => Scaffold(
        backgroundColor: Colors.grey[100], // Düz ve modern arka plan
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Başlık
                      Text(
                        "Yeni Görev Ekle",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Personel Seçim Kartı
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: secilenMail.isNotEmpty ? Colors.blue.shade50 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: secilenMail.isNotEmpty ? Colors.blue.shade200 : Colors.grey.shade300,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.person, color: Colors.blueGrey, size: 22),
                                SizedBox(width: 8),
                                Text(
                                  'Seçili Personel',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueGrey[700],
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            if (secilenMail.isEmpty)
                              Text(
                                'Henüz personel seçilmedi',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue.shade300),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person, size: 16, color: Colors.blue.shade700),
                                    SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        secilenMail,
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          secilenMail = "";
                                        });
                                      },
                                      child: Icon(Icons.close, size: 16, color: Colors.blue.shade700),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),

                      // Görev Başlığı
                      TextFormField(
                        controller: gorevBaslik,
                        decoration: InputDecoration(
                          labelText: 'Görev Başlığı',
                          prefixIcon: Icon(Icons.title_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                          value == null || value.isEmpty ? 'Görev Başlığı Giriniz' : null,
                      ),
                      SizedBox(height: 16),

                      // Görev İçerik
                      TextFormField(
                        controller: gorevIcerik,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Görev İçeriği',
                          prefixIcon: Icon(Icons.task_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                          value == null || value.isEmpty ? 'Görev içeriği Giriniz' : null,
                      ),
                      SizedBox(height: 16),

                      // Tarih Seçici
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: gorevTarih,
                            decoration: InputDecoration(
                              labelText: "Son Tarih",
                              prefixIcon: Icon(Icons.date_range_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 18),

                      // Butonlar Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Personel Seç
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showModalBottomSheet(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                                  ),
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) => StatefulBuilder(
                                    builder: (BuildContext context, StateSetter setModalState) =>
                                      Container(
                                        height: MediaQuery.of(context).size.height * 0.7,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(24),
                                              child: Text(
                                                'Görevi Vereceğiniz Personeli Seçiniz',
                                                style: TextStyle(
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blueGrey[900]
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                                child: StreamBuilder(
                                                  stream: FirebaseFirestore.instance
                                                      .collection('Kullanicilar')
                                                      .snapshots(),
                                                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                                      return Center(child: CircularProgressIndicator());
                                                    } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                                      return Center(child: Text("Kullanıcı bulunamadı."));
                                                    } else {
                                                      final documents = snapshot.data!.docs;
                                                      return ListView.builder(
                                                        controller: _modalScrollController,
                                                        itemCount: documents.length,
                                                        itemBuilder: (context, index) {
                                                          String email = documents[index]['email'];
                                                          bool isSelected = secilenMail == email;
                                                          return AnimatedContainer(
                                                            duration: Duration(milliseconds: 150),
                                                            margin: EdgeInsets.symmetric(vertical: 7, horizontal: 3),
                                                            decoration: BoxDecoration(
                                                              color: isSelected ? Colors.blue.shade50 : Colors.white,
                                                              borderRadius: BorderRadius.circular(16),
                                                              border: Border.all(
                                                                color: isSelected ? Colors.blue : Colors.grey.shade300,
                                                                width: 2,
                                                              ),
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: isSelected
                                                                      ? Colors.blue.withOpacity(0.1)
                                                                      : Colors.grey.withOpacity(0.04),
                                                                  blurRadius: 10,
                                                                  offset: Offset(0, 2),
                                                                ),
                                                              ],
                                                            ),
                                                            child: ListTile(
                                                              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                                              leading: CircleAvatar(
                                                                backgroundColor: isSelected ? Colors.blue : Colors.grey.shade300,
                                                                child: Icon(Icons.person, color: Colors.white),
                                                              ),
                                                              title: Text(
                                                                email,
                                                                style: TextStyle(
                                                                  fontSize: 15.5,
                                                                  fontWeight: FontWeight.w600,
                                                                  color: isSelected ? Colors.blue.shade700 : Colors.black87,
                                                                ),
                                                              ),
                                                              onTap: () {
                                                                setModalState(() {
                                                                  secilenMail = isSelected ? "" : email;
                                                                });
                                                                setState(() {
                                                                  secilenMail = isSelected ? "" : email;
                                                                });
                                                              },
                                                              trailing: isSelected
                                                                  ? Icon(Icons.check_circle_rounded, color: Colors.blue, size: 28)
                                                                  : Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(24),
                                              child: ElevatedButton(
                                                onPressed: secilenMail.isNotEmpty
                                                    ? () {
                                                        Navigator.pop(context);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: Text('$secilenMail seçildi'),
                                                            backgroundColor: Colors.green,
                                                            duration: Duration(seconds: 2),
                                                          ),
                                                        );
                                                      }
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: secilenMail.isNotEmpty ? Colors.blue : Colors.grey,
                                                  foregroundColor: Colors.white,
                                                  padding: EdgeInsets.symmetric(vertical: 15),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(18),
                                                  ),
                                                  elevation: secilenMail.isNotEmpty ? 5 : 0,
                                                ),
                                                child: Text(
                                                  secilenMail.isNotEmpty
                                                      ? 'Onayla ($secilenMail)'
                                                      : 'Personel Seçiniz',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.person_add_alt_1),
                              label: Text("Personel Seç"),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          // Kaydet
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  if (secilenMail.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Bir personel seçmelisiniz!'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  await context
                                      .read<GorevEkleViewModel>()
                                      .addYeniGorev(
                                          gorevBaslikbireysel: gorevBaslik.text,
                                          gorevIcerikbireysel: gorevIcerik.text,
                                          personelMail: secilenMail.isNotEmpty
                                              ? secilenMail
                                              : (FirebaseAuth.instance.currentUser?.email ?? ""),
                                          sonTarih: selectFormat)
                                      .then((value) => Message('Görev Başarıyla Eklendi'))
                                      .then((value) {
                                    gorevBaslik.clear();
                                    gorevIcerik.clear();
                                    gorevTarih.clear();
                                    secilenMail = '';
                                  });
                                }
                              },
                              icon: Icon(Icons.save_alt_rounded),
                              label: Text("Kaydet"),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Colors.green[700],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Geri Dön FAB
                      SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FloatingActionButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => AdminAnasayfaView()),
                                ((route) => false));
                          },
                          child: Icon(Icons.arrow_back),
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.blueGrey[900],
                          elevation: 0,
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
