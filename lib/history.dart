import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ujikom_jurnalprakerin/koneksi.dart';

class HalamanHistory extends StatefulWidget {
  const HalamanHistory({super.key});

  @override
  State<HalamanHistory> createState() => _HalamanHistoryState();
}

class _HalamanHistoryState extends State<HalamanHistory> {
  List formulir = [];
  DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  Future<void> getFormulir() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? siswaId = shared.getString('id_siswa');
    String? token = shared.getString('token');
    final response = await http.get(
        Uri.parse(koneksi().baseUrl + 'formulir/show/$siswaId?token=$token'));

    log(siswaId.toString());
    log(response.body);
    if (response.statusCode == 200) {
      setState(() {
        formulir = jsonDecode(response.body)['absensi'];
      });
    } else {
      log(response.body);
    }
  }

  @override
  void initState() {
    super.initState();
    getFormulir();
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
              'Histori Kehadiran',
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
                Row(
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
                SizedBox(height: 30),
                formulir.isEmpty
                    ? Image.asset('assets/images/nodata.jpg')
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: formulir.length,
                        itemBuilder: (BuildContext context, int index) {
                          final item = formulir[index];
                          Color borderColor = Colors.white; // Warna default
                          Color color = Colors.white; // Warna default

                          // Tentukan warna berdasarkan status
                          if (item['status'] == 'izin') {
                            borderColor = const Color.fromARGB(255, 225, 90, 80)
                                .withAlpha(90);
                            color = const Color.fromARGB(255, 225, 90, 80)
                                .withAlpha(55);
                          } else if (item['status'] == 'hadir') {
                            borderColor = Color.fromARGB(255, 108, 172, 140)
                                .withAlpha(90);
                            color = Color.fromARGB(255, 108, 172, 140)
                                .withAlpha(55);
                          } else if (item['status'] == 'sakit') {
                            borderColor = Colors.orangeAccent.withAlpha(90);
                            color = Colors.orangeAccent.withAlpha(55);
                          }
                          return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border:
                                    Border.all(color: borderColor, width: 2),
                                color: color),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _dateFormat.format(
                                        DateTime.parse(item['created_at'])),
                                    style: TextStyle(color: Colors.grey[900]),
                                  ),
                                  Text(
                                    item['status'] ?? '',
                                    style: TextStyle(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(
                                    item['alasan'] ?? '-',
                                    style: TextStyle(
                                        color: Colors.grey[900],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
