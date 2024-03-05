import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ujikom_jurnalprakerin/bottom_navigation.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';

class HalamanAbsensiPulang extends StatefulWidget {
  const HalamanAbsensiPulang({super.key});

  @override
  State<HalamanAbsensiPulang> createState() => _HalamanAbsensiPulangState();
}

class _HalamanAbsensiPulangState extends State<HalamanAbsensiPulang> {
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  bool isLoading = false;

  Future<void> absenPulang() async {
    setState(() {
      isLoading = true;
    });
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    String latitude = position.latitude.toString();
    String longitude = position.longitude.toString();

    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    final String tanggalSekarang =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    String jamPulang = DateFormat('HH:mm:ss').format(DateTime.now());
    final response = await http.post(
      Uri.parse(koneksi().baseUrl + 'kehadiran/absensi/pulang?token=$token'),
      body: {
        'latitude': latitude,
        'longitude': longitude,
        'jam_pulang': jamPulang,
        'tanggal': tanggalSekarang,
      },
    );
    log(response.body);
    if (response.statusCode == 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Silahkan lakukan absen masuk terlebih dahulu!'),
          backgroundColor: Colors.red,
        ),
      );
    }
    if (response.statusCode == 403) {
      log(response.body);
      _showAlertDialog();
    } else {
      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => BottomNavigation(id: 1),
        ));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Berhasil'),
          ),
        );
      }
      if (response.statusCode == 409) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
    });
  }

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _showAlertDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text('Peringatan')),
          content: Text(
            'Kamu tidak berada dalam radius tempat prakerin',
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            InkWell(
              onTap: () {
                Navigator.pop(context, true);
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
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Layanan lokasi tidak aktif');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Izin lokasi ditolak secara permanen');
    }
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error('Izin lokasi ditolak');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatHari = DateFormat('EEEE', 'id_ID');
    final formatWaktu = DateFormat('HH:mm', 'id_ID');
    final formatTanggal = DateFormat('d MMMM y', 'id_ID');
    return Center(
      child: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 420,
                  padding: EdgeInsets.only(left: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                    child: Column(
                      children: [
                        Text(
                          formatWaktu.format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          formatHari.format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          formatTanggal.format(DateTime.now()),
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),
                        Stack(
                          children: [
                            CustomPaint(
                              size: Size(180, 180),
                              painter: ThreeColorCirclePainter(),
                            ),
                            Positioned(
                              top: 80,
                              left: 60,
                              child: InkWell(
                                onTap: () {
                                  absenPulang();
                                },
                                child: isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.white)
                                    : Text(
                                        "Pulang",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Ketentuan:',
                          style: TextStyle(
                            color: Color.fromARGB(255, 1, 101, 147),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Pastikan anda berada pada radius 50 m dari tempat prakerin',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThreeColorCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()..color = Color.fromARGB(150, 3, 133, 194);
    var paint2 = Paint()..color = Color.fromARGB(187, 1, 101, 147);
    var paint3 = Paint()..color = Color.fromARGB(255, 1, 101, 147);

    var center = Offset(size.width / 2, size.height / 2);
    var radius = size.width / 2;

    canvas.drawCircle(center, radius, paint1);
    canvas.drawCircle(center, radius - 10, paint2);
    canvas.drawCircle(center, radius - 25, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
