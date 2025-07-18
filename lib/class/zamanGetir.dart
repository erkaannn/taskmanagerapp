import 'package:intl/intl.dart';

class Zaman{
  var list7 = [];
  var list15 = [];
  var list30 = [];
  void zamanAyar() {
    var now = DateTime.now();
    var baslangic = DateFormat('dd/MM/yyyy').format(now);

    list7 = [];
    list15 = [];
    list30 = [];
    for (var i = 0; i < 7; i++) {
      var addDah = Duration(days: i);
      var AddDate = now.add(addDah);
      var addDate2 = DateFormat('dd/MM/yyyy').format(AddDate);
      list7.add(addDate2);
    }
    for (var i = 0; i < 15; i++) {
      var addDah = Duration(days: i);
      var AddDate = now.add(addDah);
      var addDate2 = DateFormat('dd/MM/yyyy').format(AddDate);
      list15.add(addDate2);
    }
    for (var i = 0; i < 30; i++) {
      var addDah = Duration(days: i);
      var AddDate = now.add(addDah);
      var addDate2 = DateFormat('dd/MM/yyyy').format(AddDate);
      list30.add(addDate2);
    }
  }
}