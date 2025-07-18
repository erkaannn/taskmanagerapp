import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taskmanagmentapp/PersonelSayfalar/personelAnaSayfa.dart';

import '../Widgets/bottomNavigationBar.dart';
import '../class/image2.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class PersonelAyar extends StatefulWidget {
  const PersonelAyar({super.key});

  @override
  State<PersonelAyar> createState() => _PersonelAyarState();
}

class _PersonelAyarState extends State<PersonelAyar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Profil Ayarları',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: PersonelAyarWidget(),
    );
  }
}

class PersonelAyarWidget extends StatefulWidget {
  @override
  State<PersonelAyarWidget> createState() => _PersonelAyarWidgetState();
}

class _PersonelAyarWidgetState extends State<PersonelAyarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool _isPasswordChangeEnabled = false;
  bool _isLoading = false;
  final _passwordVisible = true.obs;

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  void _togglePasswordVisibility() {
    _passwordVisible(!_passwordVisible.value);
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection("Kullanicilar")
          .doc('${auth.currentUser!.email}')
          .update({
        'email': _emailController.text.trim(),
        'sifre': _passwordController.text.trim(),
        'Ad': _nameController.text.trim(),
        'Soyad': _surnameController.text.trim(),
        'Gorev': _roleController.text.trim(),
        'Tel': _phoneController.text.trim(),
      });

      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Profil başarıyla güncellendi!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      // Ana sayfaya yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PersonelAnaSayfa()),
      );
    } catch (e) {
      // Hata mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Text('Güncelleme sırasında hata oluştu!'),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Query usersStream = FirebaseFirestore.instance
        .collection('Kullanicilar')
        .where("kullaniciID", isEqualTo: auth.currentUser!.uid);

    return StreamBuilder<QuerySnapshot>(
      stream: usersStream.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red[300]),
                SizedBox(height: 16),
                Text(
                  'Bir hata oluştu',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  'Yükleniyor...',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                // Controllers'a veri ata
                _nameController.text = data['Ad'] ?? '';
                _surnameController.text = data['Soyad'] ?? '';
                _roleController.text = data['Gorev'] ?? '';
                _phoneController.text = data['Tel'] ?? '';
                _emailController.text = data['email'] ?? '';
                _passwordController.text = data['sifre'] ?? '';

                return Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profil Resmi
                      _buildProfileImageSection(),
                      
                      SizedBox(height: 30),
                      
                      // Form Alanları
                      _buildFormSection(),
                      
                      SizedBox(height: 20),
                      
                      // Şifre Değiştirme Checkbox
                      _buildPasswordToggle(),
                      
                      SizedBox(height: 10),
                      
                      // Şifre Alanı (Koşullu)
                      if (_isPasswordChangeEnabled) _buildPasswordField(),
                      
                      SizedBox(height: 30),
                      
                      // Güncelle Butonu
                      _buildUpdateButton(),
                      
                      SizedBox(height: 20),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileImageSection() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: ClipOval(
              child: ImageGet() ?? Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField(
              controller: _nameController,
              label: 'Ad',
              icon: Icons.person_outline,
              hint: 'Adınızı girin',
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _surnameController,
              label: 'Soyad',
              icon: Icons.person_outline,
              hint: 'Soyadınızı girin',
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _roleController,
              label: 'Görev',
              icon: Icons.work_outline,
              hint: 'Görevinizi girin',
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Telefon',
              icon: Icons.phone_outlined,
              hint: 'Telefon numaranızı girin',
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'E-posta',
              icon: Icons.email_outlined,
              hint: 'E-posta adresiniz',
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    bool readOnly = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[400]),
        suffixIcon: readOnly 
            ? Icon(Icons.lock_outline, color: Colors.grey[400]) 
            : Icon(Icons.edit_outlined, color: Colors.grey[400]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey[50] : Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildPasswordToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: CheckboxListTile(
        title: Text(
          "Şifrenizi değiştirmek istiyor musunuz?",
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        controlAffinity: ListTileControlAffinity.leading,
        value: _isPasswordChangeEnabled,
        onChanged: (value) {
          setState(() {
            _isPasswordChangeEnabled = value!;
            if (!value) {
              _passwordController.text = '';
            }
          });
        },
        activeColor: Colors.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Obx(
          () => TextFormField(
            controller: _passwordController,
            obscureText: _passwordVisible.value,
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              labelText: 'Yeni Şifre',
              hintText: 'Yeni şifrenizi girin',
              prefixIcon: Icon(Icons.lock_outline, color: Colors.blue[400]),
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey[600],
                ),
                onPressed: _togglePasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _updateProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Güncelleniyor...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.update, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Profili Güncelle',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}