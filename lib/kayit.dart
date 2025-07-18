import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController eMail = TextEditingController();
  TextEditingController sifre = TextEditingController();
  TextEditingController sifre1 = TextEditingController();
  TextEditingController kullaniciAdi = TextEditingController();
  TextEditingController kullaniciSoyadi = TextEditingController();
  TextEditingController kullaniciGorev = TextEditingController();
  TextEditingController kullaniciTel = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  "Kayıt Ol",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 32),

                _buildTextField(kullaniciAdi, 'Ad', Icons.person),
                SizedBox(height: 16),

                _buildTextField(kullaniciSoyadi, 'Soyad', Icons.person_outline),
                SizedBox(height: 16),

                _buildTextField(kullaniciGorev, 'Görev', Icons.work_outline),
                SizedBox(height: 16),

                _buildPhoneField(kullaniciTel, 'Telefon', Icons.phone),
                SizedBox(height: 16),

                _buildEmailField(eMail, 'Email', Icons.email),
                SizedBox(height: 16),

                _buildTextField(sifre, 'Şifre', Icons.lock, isPassword: true),
                SizedBox(height: 16),

                _buildTextField(sifre1, 'Şifre Tekrar', Icons.lock_outline, isPassword: true),
                SizedBox(height: 24),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (sifre.text == sifre1.text) {
                        register();
                      } else {
                        errorMessage('Şifreler eşleşmiyor!');
                      }
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    child: Text('Kayıt Ol', style: TextStyle(fontSize: 16)),
                  ),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
                  },
                  child: Text("Zaten hesabınız var mı? Giriş yap"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label boş bırakılamaz';
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildPhoneField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label boş bırakılamaz';
        }
        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
          return 'Telefon sadece rakamlardan oluşmalıdır';
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildEmailField(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label boş bırakılamaz';
        }
        if (!value.contains('@') || !value.endsWith('.com')) {
          return 'Geçerli bir email giriniz';
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Future<void> register() async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: eMail.text.trim(),
        password: sifre.text.trim(),
      ).then((value) {
        FirebaseFirestore.instance.collection('Kullanicilar').doc(eMail.text).set({
          'kullaniciID': auth.currentUser!.uid,
          'email': eMail.text,
          'sifre': sifre.text,
          'admin': false,
          'Ad': kullaniciAdi.text,
          'Soyad': kullaniciSoyadi.text,
          'Gorev': kullaniciGorev.text,
          'Tel': kullaniciTel.text,
        });
        errorMessage('Kayıt Başarılı!');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginPage()));
      });
    } catch (e) {
      errorMessage('Bir hata oluştu: ${e.toString()}');
    }
  }

  void errorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
