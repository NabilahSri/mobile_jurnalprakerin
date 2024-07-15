import 'dart:convert';
import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom_jurnalprakerin/Pengumuman.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';

class HalamanHome extends StatefulWidget {
  const HalamanHome({super.key});

  @override
  State<HalamanHome> createState() => _HalamanHomeState();
}

class _HalamanHomeState extends State<HalamanHome> {
  int _currentPage = 0;
  final List<String> _imageList = [];
  int hadir = 0;
  int izin = 0;
  int sakit = 0;
  int jam = 0;
  int menit = 0;
  String siswa = '';
  String kelas = '';
  String foto = '';
  String userId = '';

  Future<void> showData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    userId = prefs.getString('id')!;
    final response = await http.get(Uri.parse(
        koneksi().baseUrl + 'kehadiran/dashboard/$userId?token=$token'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final dataSiswa = data['siswa'];
      log(data['siswa'].toString());
      if (mounted) {
        setState(() {
          siswa = dataSiswa['name'];
          kelas = dataSiswa['kelas'];
          foto = dataSiswa['foto'] ?? 'assets/images/profile.png';
          hadir = data['hadir'];
          izin = data['izin'];
          sakit = data['sakit'];
          jam = data['total_jam_kerja']['jam'];
          menit = data['total_jam_kerja']['menit'];
        });
      }
      SharedPreferences shared = await SharedPreferences.getInstance();
      shared.setString('absen_model', 'Lokasi');
      // shared.setString('id', userId);
      // log('userID = ' + userId);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan'),
            backgroundColor: Colors.red,
          ),
        );
      }
      log(response.body);
    }
  }

  Future<void> showBanner() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    final response = await http
        .get(Uri.parse(koneksi().baseUrl + 'banner/show?token=$token'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final List<dynamic>? banners = jsonResponse['banner'];

      log(jsonResponse['banner'].toString());

      if (banners != null) {
        if (mounted) {
          setState(() {
            _imageList.clear();
            for (int i = 0; i < banners.length; i++) {
              final banner = banners[i];
              final imageUrl = banner['gambar'];
              _imageList.add(imageUrl);
            }
          });
        }
      } else {
        setState(() {
          _imageList.clear();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    showBanner();
    showData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(270.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color.fromARGB(253, 3, 146, 213)],
                    stops: [0.02, 0.70],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    transform: GradientRotation(-90),
                  ),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30))),
            ),
            Padding(
              padding: EdgeInsets.only(top: 40, left: 15, right: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      foto == 'assets/images/profile.png'
                          ? ClipOval(
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image:
                                        AssetImage('assets/images/profile.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            )
                          : ClipOval(
                              child: Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(foto),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(height: 10),
                      Text(
                        '$siswa',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '$kelas',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 25, left: 25, right: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _imageList.isEmpty
                  ? CarouselSlider(
                      items: [
                        ClipRRect(
                          borderRadius: BorderRadiusDirectional.circular(10.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey[300],
                          ),
                        )
                      ],
                      options: CarouselOptions(
                        height: 160,
                        aspectRatio: 16 / 9,
                        viewportFraction: 0.8,
                        initialPage: 0,
                        enableInfiniteScroll: true,
                        reverse: false,
                        autoPlay: true,
                        autoPlayInterval: Duration(seconds: 3),
                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                        autoPlayCurve: Curves.fastOutSlowIn,
                        enlargeCenterPage: true,
                        onPageChanged: (index, reason) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CarouselSlider(
                        items: _imageList.map((image) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: NetworkImage(image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                        options: CarouselOptions(
                          height: 160,
                          aspectRatio: 16 / 9,
                          viewportFraction: 0.8,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                        ),
                      ),
                    ),
              SizedBox(height: 10),
              Text(
                'Lihat selengkapnya...',
                style: TextStyle(fontSize: 12),
              ),
              SizedBox(height: 40),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Colors.green.withAlpha(90),
                                    width: 2),
                                color: Colors.green.withAlpha(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        '$hadir',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Total Hadir',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Colors.orangeAccent.withAlpha(90),
                                    width: 2),
                                color: Colors.orangeAccent.withAlpha(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        '$sakit',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Total Sakit',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Colors.red.withAlpha(90), width: 2),
                                color: Colors.red.withAlpha(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        '$izin',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Total Izin',
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 90,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                    color: Colors.grey.withAlpha(90), width: 2),
                                color: Colors.grey.withAlpha(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        '$jam jam $menit menit',
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        'Total Jam Kerja',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
