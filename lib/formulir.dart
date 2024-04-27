import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ujikom_jurnalprakerin/bottom_navigation.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_error.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_success.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';

class HalamanFormulir extends StatefulWidget {
  const HalamanFormulir({super.key});

  @override
  State<HalamanFormulir> createState() => _HalamanFormulirState();
}

class _HalamanFormulirState extends State<HalamanFormulir> {
  XFile? _image;
  DateTime? pickedDate;
  String statusvalue = '';
  TextEditingController _alasanController = TextEditingController();
  bool _isLoading = false;

  Future<void> addFormulir() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? siswaId = shared.getString('id_siswa');
    String? token = shared.getString('token');
    var request = http.MultipartRequest(
      'POST',
      Uri.parse(koneksi().baseUrl + 'formulir/add?token=$token'),
    );

    final pickedDateValue = pickedDate;
    final statusValue = statusvalue;
    final alasanValue = _alasanController.text;
    final fileValue = _image != null
        ? await http.MultipartFile.fromPath('bukti', _image!.path)
        : null;

    request.fields['tanggal'] = pickedDateValue != null
        ? DateFormat('yyyy-MM-ddd').format(pickedDateValue)
        : '';
    request.fields['status'] = statusValue;
    request.fields['catatan'] = alasanValue;
    request.fields['id_siswa'] = siswaId.toString();
    if (fileValue != null) {
      request.files.add(fileValue);
    }

    try {
      var response = await request.send();
      if (response.statusCode == 201) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => BottomNavigation(id: 1),
        ));
        CustomSnackBarSuccess.show(context, 'Data berhasil di upload.');
      } else {
        CustomSnackBarError.show(context, 'Data gagal di upload!');
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
            backgroundColor: Color.fromARGB(253, 3, 146, 213),
            automaticallyImplyLeading: true,
            centerTitle: true,
            title: Text(
              'Formulir',
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
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      print(picked);
                      setState(() {
                        pickedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    height: 55,
                    padding: EdgeInsets.only(top: 3, left: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        pickedDate != null
                            ? DateFormat.yMd().format(pickedDate!)
                            : 'Pilih Tanggal',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  height: 55,
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
                  child: SearchableDropdown<String>(
                    hintText: Text('Pilih Status Keterangan'),
                    items: [
                      SearchableDropdownMenuItem(
                        value: 'sakit',
                        label: 'sakit',
                        child: Text('Sakit'),
                      ),
                      SearchableDropdownMenuItem(
                        value: 'izin',
                        label: 'izin',
                        child: Text('Izin'),
                      ),
                    ],
                    onChanged: (String? value) {
                      debugPrint('$value');
                      setState(() {
                        statusvalue = value!;
                      });
                    },
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
                    controller: _alasanController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Catatan",
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
                    addFormulir();
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
