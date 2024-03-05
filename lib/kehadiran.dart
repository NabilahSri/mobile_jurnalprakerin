import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:searchable_paginated_dropdown/searchable_paginated_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom_jurnalprakerin/absensi.dart';
import 'package:ujikom_jurnalprakerin/formulir.dart';
import 'package:ujikom_jurnalprakerin/history.dart';
import 'package:http/http.dart' as http;
import 'package:ujikom_jurnalprakerin/koneksi.dart';
import 'package:ujikom_jurnalprakerin/tab_bar.dart';

class HalamanKehadiran extends StatefulWidget {
  const HalamanKehadiran({super.key});

  @override
  State<HalamanKehadiran> createState() => _HalamanKehadiranState();
}

class _HalamanKehadiranState extends State<HalamanKehadiran> {
  int _rowsPerPage = 5;
  int _totalRows = 0;
  List kehadiran = [];
  late DataTableSource ourdata = myData([]);
  bool _isDataAvailable = true;

  Future<void> getKehadiran() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? userId = shared.getString('id');
    String? token = shared.getString('token');
    final response = await http.get(
        Uri.parse(koneksi().baseUrl + 'kehadiran/show/$userId?token=$token'));

    if (response.statusCode == 200) {
      setState(() {
        kehadiran = jsonDecode(response.body)['kehadiran'];
        _totalRows = myData(kehadiran).rowCount;
        ourdata = myData(kehadiran);
        _rowsPerPage = _totalRows > _rowsPerPage ? _rowsPerPage : _totalRows;
        _isDataAvailable = kehadiran.isNotEmpty;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
    });
  }

  @override
  void initState() {
    super.initState();
    getKehadiran();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formatHari = DateFormat('EEEE', 'id_ID');
    final formatWaktu = DateFormat('HH:mm', 'id_ID');
    final formatTanggal = DateFormat('d MMMM y', 'id_ID');
    int _totalPages;

    if (_totalRows.isFinite && _rowsPerPage.isFinite && _rowsPerPage != 0) {
      _totalPages = (_totalRows / _rowsPerPage).ceil();
    } else {
      print('Error: Invalid values for _totalRows or _rowsPerPage');
      _totalPages = 1;
    }

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
            centerTitle: true,
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromARGB(255, 0, 1, 102),
            title: Text(
              'Kehadiran',
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
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatWaktu.format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              formatHari.format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatTanggal.format(DateTime.now()),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => Tab_Bar(),
                                    ));
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 0, 160, 234),
                                    foregroundColor: Colors.white,
                                    fixedSize: Size(90, 85),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text('Absen',
                                      style: TextStyle(fontSize: 18)),
                                ),
                              ],
                            ),
                            SizedBox(width: 5),
                            Column(
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => HalamanFormulir(),
                                    ));
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 0, 160, 234),
                                    foregroundColor: Colors.white,
                                    fixedSize: Size(85, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text('Formulir',
                                      style: TextStyle(fontSize: 18)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => HalamanHistory(),
                                    ));
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 0, 160, 234),
                                    foregroundColor: Colors.white,
                                    fixedSize: Size(85, 40),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text('Histori',
                                      style: TextStyle(fontSize: 18)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
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
                      child: SearchableDropdown<int>(
                        hintText: Text('Pilih Bulan'),
                        items: [
                          SearchableDropdownMenuItem(
                            value: 1,
                            label: 'januari',
                            child: Text('Januari'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 2,
                            label: 'februari',
                            child: Text('Februari'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 3,
                            label: 'maret',
                            child: Text('Maret'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 4,
                            label: 'april',
                            child: Text('April'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 5,
                            label: 'mei',
                            child: Text('Mei'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 6,
                            label: 'juni',
                            child: Text('Juni'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 7,
                            label: 'juli',
                            child: Text('Juli'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 8,
                            label: 'agustus',
                            child: Text('Agustus'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 9,
                            label: 'september',
                            child: Text('September'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 10,
                            label: 'oktober',
                            child: Text('Oktober'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 11,
                            label: 'november',
                            child: Text('Novenber'),
                          ),
                          SearchableDropdownMenuItem(
                            value: 12,
                            label: 'desember',
                            child: Text('Desember'),
                          ),
                        ],
                        onChanged: (int? value) {
                          debugPrint('$value');
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      child: _isDataAvailable
                          ? PaginatedDataTable(
                              columns: [
                                DataColumn(label: Text("Tanggal")),
                                DataColumn(label: Text("Jam Masuk")),
                                DataColumn(label: Text("Jam Pulang")),
                                DataColumn(label: Text("Status")),
                              ],
                              source: ourdata,
                              columnSpacing: 34,
                              horizontalMargin: 30,
                              rowsPerPage: _rowsPerPage,
                            )
                          : Text('Data tidak tersedia'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class myData extends DataTableSource {
  List<dynamic> data;

  myData(this.data);

  @override
  DataRow? getRow(int index) {
    if (index < data.length) {
      final item = data[index];
      return DataRow(cells: [
        DataCell(Text(item['tanggal'] ?? '')),
        DataCell(Text(item['jam_masuk'] ?? '')),
        DataCell(Text(item['jam_pulang'] ?? '-')),
        DataCell(Text(item['status'] ?? '')),
      ]);
    } else {
      return null;
    }
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  // TODO: implement rowCount
  int get rowCount => data.length;

  @override
  // TODO: implement selectedRowCount
  int get selectedRowCount => 0;
}
