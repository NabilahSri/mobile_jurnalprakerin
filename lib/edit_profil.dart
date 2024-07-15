import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom_jurnalprakerin/bottom_navigation.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_error.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_success.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:ujikom_jurnalprakerin/profil.dart';

class HalamanEditProfil extends StatefulWidget {
  const HalamanEditProfil({super.key});

  @override
  State<HalamanEditProfil> createState() => _HalamanEditProfilState();
}

class _HalamanEditProfilState extends State<HalamanEditProfil> {
  bool _isLoading = false;
  File? _image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telpController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  Map<String, dynamic> userData = {};
  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? userId = shared.getString('id');
    String? token = shared.getString('token');
    log('lalala');
    log(userId.toString());
    log(token.toString());
    final response = await http
        .get(Uri.parse(koneksi().baseUrl + 'auth/show/$userId?token=$token'));
    log('haiii');
    if (response.statusCode == 200) {
      log('hohoohoh');
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        if (mounted) {
          setState(() {
            userData = jsonResponse['user'];
            nameController.text = userData['name'];
            emailController.text = userData['email'];
            telpController.text = userData['telp'];
            alamatController.text = userData['alamat'];
          });
        }
        log(userData.toString());
        log(userData['foto'].toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _takePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Pilih Sumber Gambar"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text("Ambil dari Galeri"),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Ambil Foto"),
                onTap: () {
                  Navigator.of(context).pop();
                  _takePicture();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> editData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? siswaId = shared.getString('id_siswa');
    String? token = shared.getString('token');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(koneksi().baseUrl + 'auth/editProfil/$siswaId?token=$token'),
    );

    final nameValue = nameController.text;
    final emailValue = emailController.text;
    final telpValue = telpController.text;
    final alamatValue = alamatController.text;

    final fileValue = _image != null
        ? await http.MultipartFile.fromPath('foto', _image!.path)
        : null;

    request.fields['name'] = nameValue;
    request.fields['email'] = emailValue;
    request.fields['telp'] = telpValue;
    request.fields['alamat'] = alamatValue;
    if (fileValue != null) {
      request.files.add(fileValue);
    }

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => BottomNavigation(id: 3),
        ));
        CustomSnackBarSuccess.show(context, 'Data berhasil di update.');
      } else {
        CustomSnackBarError.show(context, 'Data gagal di update!');
      }
    } catch (e) {
      log('kesalahan server');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Color.fromARGB(255, 0, 160, 234),
            title: Text(
              'Edit Profil',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Color.fromARGB(255, 0, 160, 234),
              ),
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            _image == null
                                ? userData['foto'] != null
                                    ? ClipOval(
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                  userData['foto']),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      )
                                    : ClipOval(
                                        child: Container(
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/profile.png'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      )
                                : ClipOval(
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: FileImage(_image!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                            InkWell(
                              onTap: () {
                                _showImagePickerDialog(context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(Icons.edit, color: Colors.black),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 55,
                        padding: EdgeInsets.only(top: 3, left: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7,
                              )
                            ]),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: nameController,
                          onChanged: (value) {
                            nameController.text = value;
                          },
                          decoration: InputDecoration(
                            hintText: "Masukan nama",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 55,
                        padding: EdgeInsets.only(top: 3, left: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7,
                              )
                            ]),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: emailController,
                          onChanged: (value) {
                            emailController.text = value;
                          },
                          decoration: InputDecoration(
                            hintText: "Masukan email",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 55,
                        padding: EdgeInsets.only(top: 3, left: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7,
                              )
                            ]),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: telpController,
                          onChanged: (value) {
                            telpController.text = value;
                          },
                          decoration: InputDecoration(
                            hintText: "Masuka no telepon",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 100,
                        padding: EdgeInsets.only(top: 3, left: 15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 7,
                              )
                            ]),
                        child: TextFormField(
                          maxLines: 3,
                          keyboardType: TextInputType.text,
                          controller: alamatController,
                          onChanged: (value) {
                            alamatController.text = value;
                          },
                          decoration: InputDecoration(
                            hintText: "Masukan alamat",
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      InkWell(
                        onTap: () {
                          editData();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 0, 160, 234),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Simpan Perubahan',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
