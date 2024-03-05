import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom_jurnalprakerin/bottom_navigation.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';
import 'package:http/http.dart' as http;

class HalamanEditKegiatan extends StatefulWidget {
  final String kegiatanId;

  const HalamanEditKegiatan({super.key, required this.kegiatanId});

  @override
  State<HalamanEditKegiatan> createState() => _HalamanEditKegiatanState();
}

class _HalamanEditKegiatanState extends State<HalamanEditKegiatan> {
  TextEditingController _deskripsiController = TextEditingController();
  TextEditingController _durasiController = TextEditingController();
  Map<String, dynamic> kegiatan = {};
  XFile? _image;
  bool _isLoading = false;
  Future<void> getKegiatanIdKegiatan() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    final response = await http.get(Uri.parse(koneksi().baseUrl +
        'kegiatan/showIdKegiatan/${widget.kegiatanId}?token=$token'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        kegiatan = jsonResponse['kegiatan'];
        _deskripsiController.text = kegiatan['deskripsi'];
        _durasiController.text = kegiatan['durasi'].toString();
      });
      log(kegiatan.toString());
    } else {
      log(response.body);
    }
  }

  Future<void> editKegiatan() async {
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
      Uri.parse(koneksi().baseUrl +
          'kegiatan/edit/${widget.kegiatanId}?token=$token'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil di update'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data gagal di upload'),
            backgroundColor: Colors.red,
          ),
        );
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
  void initState() {
    getKegiatanIdKegiatan();
    super.initState();
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
            backgroundColor: Color.fromARGB(255, 0, 1, 102),
            title: Text(
              'Edit Kegiatan',
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
                        backgroundColor: Color.fromARGB(255, 0, 160, 234),
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
                    editKegiatan();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 1, 102),
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
