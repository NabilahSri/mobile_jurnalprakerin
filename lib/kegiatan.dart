import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom_jurnalprakerin/bottom_navigation.dart';
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

  Future<void> validasiAbsen() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    final response = await http.get(
      Uri.parse(koneksi().baseUrl + 'formulir/validasiAbsen?token=$token'),
    );
    log(response.body);
    if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silahkan lakukan absen terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HalamanTambahKegiatan(),
      ));
    }
  }

  Future<void> deleteKegiatan(String kegiatanId) async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    if (token != null) {
      bool? confirmLogout = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Hapus Kegiatan')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Yakin ingin menghapus data ini?'),
              ],
            ),
            actions: [
              InkWell(
                onTap: () {
                  Navigator.pop(context, true);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 0, 1, 102),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Ya',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              InkWell(
                onTap: () {
                  Navigator.pop(context, false);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (confirmLogout == true) {
        final response = await http.get(
          Uri.parse(
              koneksi().baseUrl + 'kegiatan/delete/$kegiatanId?token=$token'),
        );
        log(kegiatanId);
        log(response.body);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data berhasil dihapus'),
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => BottomNavigation(id: 2)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Data gagal dihapus'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> getKegiatan() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? userId = shared.getString('id');
    String? token = shared.getString('token');
    final response = await http.get(
        Uri.parse(koneksi().baseUrl + 'kegiatan/show/$userId?token=$token'));

    if (response.statusCode == 200) {
      setState(() {
        kegiatan = jsonDecode(response.body)['kegiatan'];
        _isDataAvailable = kegiatan.isNotEmpty;
      });
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
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromARGB(255, 0, 1, 102),
            title: Text(
              'Daftar Kegiatan',
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Daftar kegiatan hari ini:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 10),
                _isDataAvailable
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: kegiatan.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = kegiatan[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(item['deskripsi'] ?? ''),
                              subtitle: Text((item['durasi'] ?? '') + " menit"),
                              trailing: Container(
                                width: 100, // Set the desired width
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HalamanEditKegiatan(
                                              kegiatanId: item['id'].toString(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        deleteKegiatan(item['id'].toString());
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Center(child: Text('Data tidak tersedia')),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 0, 160, 234),
        tooltip: 'Tambah kegiatan',
        onPressed: () {
          validasiAbsen();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
