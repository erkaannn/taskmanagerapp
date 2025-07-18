import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'kayit.dart';
import 'Widgets/bottomNavigationBar.dart';
import 'mvvm/views/admin_anasayfa.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _passwordVisible = true.obs;
  TextEditingController kullaniciAdi = TextEditingController();
  TextEditingController kullaniciSifre = TextEditingController();

  void storeStatusOpen(bool isOpen) {
    _passwordVisible(isOpen);
  }

  Future<void> login() async {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: kullaniciAdi.text, password: kullaniciSifre.text)
        .then((value) async {
      var gelenDurum = await adminGiris(kullaniciAdi.text);
      if (gelenDurum == false) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Example()),
            ((route) => false));
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AdminAnasayfaView()),
            ((route) => false));
      }
    }).catchError((dynamic error) {
      if (error.toString().contains('invalid-email')) {
        errorMessage('Geçersiz Eposta');
      }
      if (error.toString().contains('user-not-found')) {
        errorMessage('Kullanıcı Bulunamadı');
      }
      if (error.toString().contains('wrong-password')) {
        errorMessage('Yanlış Şifre');
      }
    });
  }

  errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 90, color: Colors.blue),
              SizedBox(height: 20),
              Text(
                "Hoşgeldiniz",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Lütfen giriş yapın",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
              ),
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: kullaniciAdi,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.blue),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Obx(() => TextField(
                          controller: kullaniciSifre,
                          obscureText: _passwordVisible.value,
                          decoration: InputDecoration(
                            labelText: "Şifre",
                            prefixIcon: Icon(Icons.lock_outline, color: Colors.blue),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                storeStatusOpen(!_passwordVisible.value);
                              },
                            ),
                          ),
                        )),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => login(),
                        child: Text("Giriş Yap", style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue.shade700,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Hesabınız yok mu?",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterPage()),
                              ((route) => false));
                        },
                        child: Text("Kayıt Ol", style: TextStyle(fontSize: 18)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue.shade700, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> adminGiris(var y) async {
    var gelenDurum;
    await FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(y)
        .get()
        .then((gelenVeri) {
      setState(() {
        gelenDurum = gelenVeri.data()!['admin'];
      });
    });
    return Future.value(gelenDurum);
  }
}
