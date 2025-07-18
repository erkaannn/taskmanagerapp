import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/bireyselGorev.dart';
import 'admin_anasayfa.dart';
import 'gorev_goruntule_model.dart';

class GorevGoruntule extends StatefulWidget {
  const GorevGoruntule({super.key});

  @override
  State<GorevGoruntule> createState() => _GorevGoruntuleState();
}

class _GorevGoruntuleState extends State<GorevGoruntule> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<GorevGoruntuleViewModel>(
      create: (_) => GorevGoruntuleViewModel(),
      builder: (context, child) => Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Görevleri Görüntüle',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AdminAnasayfaView()),
                (route) => false,
              );
            },
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.blue[600],
                size: 20,
              ),
            ),
          ),
        ),
        body: StreamBuilder<List<bireyselGorev>>(
          stream: Provider.of<GorevGoruntuleViewModel>(context, listen: false)
              .getBireyselGorevler(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.hasError) {
              print(asyncSnapshot.error);
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Bir Hata Oluştu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Daha sonra tekrar deneyiniz',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Görevler yükleniyor...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              List<bireyselGorev> gorevList = asyncSnapshot.data!;
              return gorevList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Henüz görev bulunmuyor',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : BuildListView(gorevList: gorevList);
            }
          },
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

  final List<bireyselGorev> gorevList;

  @override
  _BuildListViewState createState() => _BuildListViewState();
}

class _BuildListViewState extends State<BuildListView> {
  DateTime selectedDate = DateTime.now();
  var selectFormat = 'asd';
  var formatter = DateFormat('dd/MM/yyyy');
  
  TextEditingController gorevBaslikController = TextEditingController();
  TextEditingController gorevIcerikController = TextEditingController();
  TextEditingController sonTarihController = TextEditingController();
  bool isFiltering = false;
  late List<bireyselGorev> filteredList;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[600]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectFormat = DateFormat('dd/MM/yyyy').format(selectedDate);
        sonTarihController.text = selectFormat;
      });
    }
  }

  void showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  Color _getPriorityColor(String date) {
    try {
      DateTime targetDate = DateFormat('dd/MM/yyyy').parse(date);
      DateTime now = DateTime.now();
      int daysDifference = targetDate.difference(now).inDays;
      
      if (daysDifference < 0) return Colors.red[100]!; // Gecikmiş
      if (daysDifference <= 3) return Colors.orange[100]!; // Acil
      if (daysDifference <= 7) return Colors.yellow[100]!; // Yakın
      return Colors.green[100]!; // Normal
    } catch (e) {
      return Colors.grey[100]!;
    }
  }

  IconData _getPriorityIcon(String date) {
    try {
      DateTime targetDate = DateFormat('dd/MM/yyyy').parse(date);
      DateTime now = DateTime.now();
      int daysDifference = targetDate.difference(now).inDays;
      
      if (daysDifference < 0) return Icons.warning;
      if (daysDifference <= 3) return Icons.priority_high;
      if (daysDifference <= 7) return Icons.schedule;
      return Icons.assignment;
    } catch (e) {
      return Icons.assignment;
    }
  }

  @override
  Widget build(BuildContext context) {
    var fullList = widget.gorevList;

    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: isFiltering ? filteredList.length : fullList.length,
        itemBuilder: (context, index) {
          final gorev = fullList[index];
          return Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showGorevDetay(gorev, index),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: _getPriorityColor(gorev.sonTarih),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getPriorityIcon(gorev.sonTarih),
                            color: Colors.grey[700],
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gorev.gorevBaslikbireysel,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    gorev.sonTarih,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showGorevDetay(bireyselGorev gorev, int index) {
    gorevBaslikController.text = gorev.gorevBaslikbireysel;
    gorevIcerikController.text = gorev.gorevIcerikbireysel;
    sonTarihController.text = gorev.sonTarih;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    "Görev Detayları",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: gorevBaslikController,
                          label: "Görev Başlığı",
                          icon: Icons.title,
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: gorevIcerikController,
                          label: "Görev İçeriği",
                          icon: Icons.description,
                          maxLines: 4,
                        ),
                        SizedBox(height: 16),
                        GestureDetector(
                          onDoubleTap: () => _selectDate(context),
                          child: _buildTextField(
                            controller: sonTarihController,
                            label: "Son Tarih (Çift tıklayın)",
                            icon: Icons.calendar_today,
                            readOnly: true,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      color: Colors.grey[600],
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      "Atanan Personel",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.blue[300]!,
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          gorev.personelMail.isNotEmpty 
                                              ? gorev.personelMail[0].toUpperCase()
                                              : '?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[700],
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            gorev.personelMail.contains('@') 
                                                ? gorev.personelMail.split('@')[0].replaceAll('.', ' ').split(' ').map((word) => 
                                                    word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
                                                  ).join(' ')
                                                : gorev.personelMail,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                              color: Colors.grey[800],
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            gorev.personelMail,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.green[400],
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close),
                          label: Text("Kapat"),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _deleteGorev(gorev),
                          icon: Icon(Icons.delete),
                          label: Text("Sil"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _updateGorev(gorev),
                          icon: Icon(Icons.save),
                          label: Text("Güncelle"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[50] : Colors.white,
      ),
    );
  }

  void _deleteGorev(bireyselGorev gorev) async {
    Navigator.of(context).pop();
    try {
      await FirebaseFirestore.instance
          .collection("BireyselGorevler")
          .doc(gorev.id)
          .delete();
      showMessage("Görev başarıyla silindi", Colors.red[600]!);
    } catch (e) {
      showMessage("Silme işlemi başarısız", Colors.red[600]!);
    }
  }

  void _updateGorev(bireyselGorev gorev) async {
    try {
      await FirebaseFirestore.instance
          .collection("BireyselGorevler")
          .doc(gorev.id)
          .update({
        'gorevBaslikbireysel': gorevBaslikController.text,
        'gorevIcerikbireysel': gorevIcerikController.text,
        'sonTarih': sonTarihController.text,
      });

      gorevBaslikController.clear();
      gorevIcerikController.clear();
      sonTarihController.clear();
      Navigator.of(context).pop();
      showMessage("Görev başarıyla güncellendi", Colors.green[600]!);
    } catch (e) {
      showMessage("Güncelleme işlemi başarısız", Colors.red[600]!);
    }
  }
}