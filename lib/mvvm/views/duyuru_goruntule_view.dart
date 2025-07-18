import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:taskmanagmentapp/mvvm/views/admin_anasayfa.dart';
import 'package:taskmanagmentapp/mvvm/views/duyuru_goruntule_model.dart';

import '../models/duyuru.dart';

class DuyuruGoruntuleView extends StatefulWidget {
  const DuyuruGoruntuleView({super.key});

  @override
  State<DuyuruGoruntuleView> createState() => _DuyuruGoruntuleViewState();
}

class _DuyuruGoruntuleViewState extends State<DuyuruGoruntuleView> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<DuyuruGoruntuleViewModel>(
      create: (_) => DuyuruGoruntuleViewModel(),
      builder: (context, child) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2196F3),
                Color(0xFF1976D2),
                Color(0xFF0D47A1),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Modern Header
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'Duyurular',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: IconButton(
                            onPressed: () {
                              // Add announcement functionality
                            },
                            icon: Icon(Icons.add, color: Colors.white, size: 24),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Content Area
                Expanded(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Header decoration
                          Container(
                            margin: EdgeInsets.only(top: 15),
                            width: 50,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          
                          // Title
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Icon(Icons.campaign, color: Color(0xFF1976D2), size: 28),
                                SizedBox(width: 10),
                                Text(
                                  'Tüm Duyurular',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // StreamBuilder
                          Expanded(
                            child: StreamBuilder<List<Duyurular>>(
                              stream: Provider.of<DuyuruGoruntuleViewModel>(context, listen: false).getDuyurular(),
                              builder: (context, asyncSnapshot) {
                                if (asyncSnapshot.hasError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                                        SizedBox(height: 16),
                                        Text(
                                          'Bir hata oluştu',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Lütfen daha sonra tekrar deneyiniz',
                                          style: TextStyle(color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (!asyncSnapshot.hasData) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                                        ),
                                        SizedBox(height: 16),
                                        Text(
                                          'Duyurular yükleniyor...',
                                          style: TextStyle(color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  List<Duyurular> duyuruList = asyncSnapshot.data!;
                                  if (duyuruList.isEmpty) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.announcement_outlined, size: 64, color: Colors.grey.shade400),
                                          SizedBox(height: 16),
                                          Text(
                                            'Henüz duyuru yok',
                                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'İlk duyuruyu ekleyin',
                                            style: TextStyle(color: Colors.grey.shade600),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  return BuildListView(gorevList: duyuruList);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BuildListView extends StatefulWidget {
  const BuildListView({
    super.key,
    required this.gorevList,
  });

  final List<Duyurular> gorevList;

  @override
  _BuildListViewState createState() => _BuildListViewState();
}

class _BuildListViewState extends State<BuildListView> with TickerProviderStateMixin {
  TextEditingController duyuruBaslik = TextEditingController();
  TextEditingController duyuruIcerik = TextEditingController();

  Message(String message, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              c == Colors.green ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: c,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var fullList = widget.gorevList;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ListView.builder(
        itemCount: fullList.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  Color(0xFFF8F9FA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showDetailDialog(context, fullList[index]),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Color(0xFF1976D2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.campaign,
                              color: Color(0xFF1976D2),
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              fullList[index].duyuruBaslik,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey.shade400,
                            size: 16,
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text(
                        fullList[index].duyuruIcerik,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Color(0xFF1976D2).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Duyuru',
                              style: TextStyle(
                                color: Color(0xFF1976D2),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Spacer(),
                          Text(
                            'Detay için tıklayın',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetailDialog(BuildContext context, Duyurular duyuru) {
    duyuruBaslik.text = duyuru.duyuruBaslik;
    duyuruIcerik.text = duyuru.duyuruIcerik;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF1976D2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.edit_document,
                      color: Color(0xFF1976D2),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      'Duyuru Detayları',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 25),
              
              // Form Fields
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: duyuruBaslik,
                  decoration: InputDecoration(
                    labelText: "Duyuru Başlığı",
                    labelStyle: TextStyle(color: Color(0xFF1976D2)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(Icons.title, color: Color(0xFF1976D2)),
                  ),
                ),
              ),
              
              SizedBox(height: 15),
              
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: duyuruIcerik,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Duyuru İçeriği",
                    labelStyle: TextStyle(color: Color(0xFF1976D2)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    prefixIcon: Icon(Icons.description, color: Color(0xFF1976D2)),
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              
              SizedBox(height: 25),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        "Kapat",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 10),
                  
                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        await FirebaseFirestore.instance
                            .collection("Duyurular")
                            .doc(duyuru.id)
                            .delete();
                        Message("Duyuru başarıyla silindi!", Colors.red);
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Sil',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 10),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection("Duyurular")
                            .doc(duyuru.id)
                            .update({
                          'duyuruBaslik': duyuruBaslik.text,
                          'duyuruIcerik': duyuruIcerik.text,
                        });
                        Message("Duyuru başarıyla güncellendi!", Colors.green);
                        duyuruBaslik.clear();
                        duyuruIcerik.clear();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1976D2),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Güncelle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}