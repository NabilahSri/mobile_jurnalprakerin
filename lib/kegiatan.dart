import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom_jurnalprakerin/bottom_navigation.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_error.dart';
import 'package:ujikom_jurnalprakerin/edit_kegiatan.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';
import 'package:ujikom_jurnalprakerin/tambah_kegiatan.dart';
import 'package:http/http.dart' as http;

class HalamanKegiatan extends StatefulWidget {
  const HalamanKegiatan({super.key});

  @override
  State<HalamanKegiatan> createState() => _HalamanKegiatanState();
}

class _HalamanKegiatanState extends State<HalamanKegiatan> {
  List kegiatan = [];
  bool _isDataAvailable = true;
  DateFormat _dateFormat = DateFormat('dd-MM-yyyy');

  Future<void> validasiAbsen() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    final response = await http.get(
      Uri.parse(koneksi().baseUrl + 'formulir/validasiAbsen?token=$token'),
    );
    log(response.statusCode.toString());
    if (response.statusCode == 400) {
      if (mounted) {
        CustomSnackBarError.show(
            context, 'Silahkan lakukan absensi terlebih dahulup!');
      }
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HalamanTambahKegiatan(),
      ));
    }
  }

  Future<void> getKegiatan() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? userId = shared.getString('id');
    String? token = shared.getString('token');
    final response = await http.get(
        Uri.parse(koneksi().baseUrl + 'kegiatan/show/$userId?token=$token'));

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          kegiatan = jsonDecode(response.body)['kegiatan'];
          _isDataAvailable = kegiatan.isNotEmpty;
        });
      }
    } else {
      log(response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    getKegiatan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(5.0),
        child: Container(
          child: Container(
            color: Color.fromARGB(253, 3, 146, 213),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Daftar Kegiatan',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
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
                                // pickedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            height: 40,
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
                                'Dari Tanggal',
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Expanded(
                        child: InkWell(
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
                                // pickedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            height: 40,
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
                                'Sampai Tanggal',
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      TextButton(
                        onPressed: () {
                          // _showImagePickerDialog(context);
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 0, 160, 234),
                          foregroundColor: Colors.white,
                          fixedSize: Size(60, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Cari'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                _isDataAvailable
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: kegiatan.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = kegiatan[index];
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5),
                              decoration: BoxDecoration(
                                  color: Color.fromARGB(150, 3, 133, 194),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15))),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => HalamanEditKegiatan(
                                        kegiatanId: item['id'].toString(),
                                      ),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _dateFormat.format(
                                            DateTime.parse(item['created_at'])),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      Text(
                                        item['deskripsi'] ?? '',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        (item['durasi'] ?? '') + " menit",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  // subtitle: Text(
                                  //   (item['durasi'] ?? '') + " menit",
                                  //   style: TextStyle(color: Colors.white),
                                  // ),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Image.asset('assets/images/nodata.jpg'),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(150, 3, 133, 194),
        tooltip: 'Tambah kegiatan',
        onPressed: () {
          validasiAbsen();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
