import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:image_picker/image_picker.dart';

class ImageGet extends StatefulWidget {
  const ImageGet({super.key});

  @override
  State<ImageGet> createState() => _ImageGetState();
}

class _ImageGetState extends State<ImageGet> {
  File? yuklenecekDosya;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  String? indirmeBaglantisi;

  void initState() {
    super.initState();
    try {
      baglantiAl();
    } catch (e) {
      print('Bağlanılamadı');
    }
  }

  baglantiAl() async {
    try {
      Reference ref = storage
          .ref()
          .child("profilResimleri")
          .child(auth.currentUser!.uid)
          .child("profilResmi.png");

      String url = await ref.getDownloadURL() == null
          ? 'Resim yok'
          : await ref.getDownloadURL();
      setState(() {
        if (url != 'Resim yok') {
          indirmeBaglantisi = url;
        }
      });
    } catch (e) {}
  }

  kameradanYukle() async {
    try {
      var alinanDosya =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      setState(() {
        yuklenecekDosya = File(alinanDosya!.path);
      });
      Reference ref = storage
          .ref()
          .child("profilResimleri")
          .child(auth.currentUser!.uid)
          .child("profilResmi.png");
      UploadTask yuklemeGorevi = ref.putFile(yuklenecekDosya!);
      String url =
          await (await yuklemeGorevi.then((res) => res.ref.getDownloadURL()));
      setState(() {
        indirmeBaglantisi = url;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          child: ClipOval(
            child: indirmeBaglantisi == null
                ? Text("Resim yok")
                : Image.network(
                    indirmeBaglantisi!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
          ),
          onTap: () {
            kameradanYukle();
          },
        ),
      ],
    );
  }
}
