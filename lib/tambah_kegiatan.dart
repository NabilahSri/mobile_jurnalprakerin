import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ujikom_jurnalprakerin/bottom_navigation.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_error.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_success.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';

class HalamanTambahKegiatan extends StatefulWidget {
  const HalamanTambahKegiatan({super.key});

  @override
  State<HalamanTambahKegiatan> createState() => _HalamanTambahKegiatanState();
}

class _HalamanTambahKegiatanState extends State<HalamanTambahKegiatan> {
  XFile? _image;
  TextEditingController _deskripsiController = TextEditingController();
  TextEditingController _durasiController = TextEditingController();
  bool _isLoading = false;

  Future<void> addKegiatan() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? siswaId = prefs.getString('id_siswa');
    String? kelasId = prefs.getString('id_kelas');
    String? absenId = prefs.getString('id_absensi');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(koneksi().baseUrl + 'kegiatan/add?token=$token'),
    );
    final deskripsiValue = _deskripsiController.text;
    final durasiValue = _durasiController.text;
    final fileValue = _image != null
        ? await http.MultipartFile.fromPath('foto', _image!.path)
        : null;
    request.fields['deskripsi'] = deskripsiValue;
    request.fields['durasi'] = durasiValue;
    request.fields['id_absensi'] = absenId.toString();
    // request.fields['id_absensi'] = '1';
    request.fields['id_siswa'] = siswaId.toString();
    request.fields['id_kelas'] = kelasId.toString();
    if (fileValue != null) {
      request.files.add(fileValue);
    }

    try {
      var response = await request.send();
      print('Response Body: ${await response.stream.bytesToString()}');
      if (response.statusCode == 201) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => BottomNavigation(id: 2),
        ));
        CustomSnackBarSuccess.show(context, 'Data berhasil diupload.');
      } else {
        CustomSnackBarError.show(context, 'Data gagal diupload!');
      }
    } catch (e) {
      log('kesalahan server');
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
        _image = pickedFile;
      });
    }
  }

  void _takePicture() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _image = pickedFile;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            centerTitle: true,
            backgroundColor: Color.fromARGB(253, 3, 146, 213),
            title: Text(
              'Tambah Kegiatan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                SizedBox(height: 15),
                Container(
                  height: 49,
                  padding: EdgeInsets.only(left: 15),
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
                    controller: _deskripsiController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Deskripsi/Kegiatan Harian",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  height: 49,
                  padding: EdgeInsets.only(left: 15),
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
                    controller: _durasiController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Durasi Pengerjaan (menit)",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        _showImagePickerDialog(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 1, 101, 147),
                        foregroundColor: Colors.white,
                        fixedSize: Size(110, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.file_upload,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 5),
                          Text('Pilih File'),
                        ],
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: _image == null
                          ? Container(
                              height: 49,
                              padding: EdgeInsets.only(left: 15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 7,
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                readOnly: true,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: "Upload File",
                                  border: InputBorder.none,
                                ),
                              ),
                            )
                          : Container(
                              height: 49,
                              padding: EdgeInsets.only(top: 4, left: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 7,
                                  ),
                                ],
                              ),
                              child: Text(_image!.path),
                            ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                InkWell(
                  onTap: () {
                    addKegiatan();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(253, 3, 146, 213),
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
                            'Kirim',
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
