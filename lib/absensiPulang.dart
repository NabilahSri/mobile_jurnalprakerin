import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ujikom_jurnalprakerin/bottom_navigation.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_error.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_success.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_warning.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class HalamanAbsensiPulang extends StatefulWidget {
  const HalamanAbsensiPulang({super.key});

  @override
  State<HalamanAbsensiPulang> createState() => _HalamanAbsensiPulangState();
}

class _HalamanAbsensiPulangState extends State<HalamanAbsensiPulang> {
  String vc = '';
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  bool isLoading = false;
  // bool sudahAbsenMasuk = false;
  final String tanggal = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Color accentPurpleColor = Color(0xFF016593);
  Color accentPinkColor = Color.fromARGB(255, 130, 177, 199);
  Color accentDarkGreenColor = Color.fromARGB(255, 49, 107, 134);
  Color accentYellowColor = Color(0xFF0B3E55);
  Color accentOrangeColor = Color.fromARGB(255, 101, 130, 143);

  TextStyle? createStyle(Color color) {
    ThemeData theme = Theme.of(context);
    return theme.textTheme.headlineMedium?.copyWith(color: color);
  }

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
    String? modeAbsen = shared.getString('absen_model');
    log(modeAbsen.toString());
    final response = await http.post(
      Uri.parse(koneksi().baseUrl + 'kehadiran/absensi/pulang?token=$token'),
      body: {
        'latitude': latitude,
        'longitude': longitude,
        'jam_pulang': jamPulang,
        'tanggal': tanggalSekarang,
        'mode': modeAbsen,
        'token_keluar': vc,
      },
    );
    log(vc);
    log(response.statusCode.toString());
    if (response.statusCode == 400) {
      CustomSnackBarWarning.show(
          context, 'Silahkan lakukan absensi masuk terlebih dahulu!');
    }
    if (response.statusCode == 404) {
      CustomSnackBarError.show(context, 'Kode Expired!');
    }
    if (response.statusCode == 401) {
      CustomSnackBarError.show(context, 'Kode tidak sesuai');
    }
    if (response.statusCode == 403) {
      log(response.body);
      _showAlertDialog();
    } else {
      if (response.statusCode == 200) {
        // final responseData = json.decode(response.body);
        // final absen = responseData['absen'];
        // final id_absensi = absen['id'].toString();
        // final tanggal_absen = absen['tanggal'];

        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('tanggal_absen', tanggal_absen);

        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => BottomNavigation(id: 0),
        ));
        CustomSnackBarSuccess.show(
            context, 'Absensi pulang berhasil dilakukan.');
      }
      if (response.statusCode == 409) {
        CustomSnackBarError.show(context, 'Gagal melakukan absensi pulang!');
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

  Future<String?> _initializeAbsensiMode() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    if (shared.getString('absen_model') != null) {
      return shared.getString('absen_model');
    } else {
      return 'Lokasi';
    }
  }

  // Future<String?> _initializetanggalAbsensi() async {
  //   SharedPreferences shared = await SharedPreferences.getInstance();
  //   final tanggal_absen = shared.getString('tanggal_absen');
  //   if (tanggal_absen != tanggal) {
  //     sudahAbsenMasuk = false;
  //   } else {
  //     sudahAbsenMasuk = true;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
    // _initializetanggalAbsensi();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: screenWidth,
            height: screenHeight,
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FutureBuilder<String?>(
                    future: _initializeAbsensiMode(),
                    builder: (context, snapshot) {
                      String? absensiMode = snapshot.data;
                      return absensiMode == 'Lokasi'
                          ? Container(
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 70, vertical: 15),
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
                                          painter:
                                              // sudahAbsenMasuk
                                              //     ? ThreeColorCirclePainterGreen()
                                              //     :
                                              ThreeColorCirclePainter(),
                                        ),
                                        Positioned(
                                          top: 80,
                                          left: 60,
                                          child:
                                              // sudahAbsenMasuk
                                              //     ? Text(
                                              //         "Selesai",
                                              //         style: TextStyle(
                                              //           fontSize: 24,
                                              //           fontWeight: FontWeight.w500,
                                              //           color: Colors.white,
                                              //         ),
                                              //       )
                                              //     :
                                              InkWell(
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
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                      'Pastikan anda berada pada radius 500 m dari tempat prakerin',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 60, vertical: 15),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
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
                                      ],
                                    ),
                                    SizedBox(height: 20),
                                    OtpTextField(
                                      numberOfFields: 5,
                                      borderColor: accentYellowColor,
                                      focusedBorderColor: accentYellowColor,
                                      showFieldAsBox: false,
                                      borderWidth: 4.0,
                                      styles: [
                                        createStyle(accentPurpleColor),
                                        createStyle(accentPinkColor),
                                        createStyle(accentDarkGreenColor),
                                        createStyle(accentYellowColor),
                                        createStyle(accentOrangeColor),
                                      ],
                                      onCodeChanged: (String code) {},
                                      onSubmit: (String verificationCode) {
                                        setState(() {
                                          vc = verificationCode;
                                        });
                                        log(vc);
                                        absenPulang();
                                      }, // end onSubmit
                                    ),
                                    SizedBox(height: 20),
                                    Column(
                                      children: [
                                        Text(
                                          'Ketentuan:',
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 1, 101, 147),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 20),
                                        Text(
                                          'Silahkan masukan kode yang sudah diberikan oleh perusahaan',
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                    }),
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
    canvas.drawCircle(center, radius - 8, paint2);
    canvas.drawCircle(center, radius - 15, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class ThreeColorCirclePainterGreen extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint1 = Paint()..color = Color.fromARGB(98, 54, 139, 79);
    var paint2 = Paint()..color = Color.fromARGB(195, 54, 139, 79);
    var paint3 = Paint()..color = Color.fromARGB(255, 54, 139, 79);

    var center = Offset(size.width / 2, size.height / 2);
    var radius = size.width / 2;

    canvas.drawCircle(center, radius, paint1);
    canvas.drawCircle(center, radius - 8, paint2);
    canvas.drawCircle(center, radius - 15, paint3);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
