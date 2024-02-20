import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom_jurnalprakerin/edit_profil.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';
import 'package:http/http.dart' as http;
import 'package:ujikom_jurnalprakerin/login.dart';

class HalamanProfil extends StatefulWidget {
  const HalamanProfil({super.key});

  @override
  State<HalamanProfil> createState() => _HalamanProfilState();
}

class _HalamanProfilState extends State<HalamanProfil> {
  bool _isLoading = false;
  bool isDataDiriVisible = false;
  bool isDataKehadiranVisible = false;
  Map<String, dynamic> userData = {};
  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? userId = shared.getString('id');
    String? token = shared.getString('token');
    final response = await http
        .get(Uri.parse(koneksi().baseUrl + 'auth/show/$userId?token=$token'));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        setState(() {
          userData = jsonResponse['user'];
        });
        log(userData.toString());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan'),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> logout() async {
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? token = shared.getString('token');
    if (token != null) {
      // Show a confirmation dialog
      bool? confirmLogout = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('Konfirmasi Keluar')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Yakin ingin keluar dari aplikasi ini?'),
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
          Uri.parse(koneksi().baseUrl + 'auth/logout?token=$token'),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Berhasil logout'),
            ),
          );
          shared.remove('token');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HalamanLogin()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal logout'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
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
            automaticallyImplyLeading: false,
            backgroundColor: Color.fromARGB(255, 0, 1, 102),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white),
                  onPressed: () async {
                    await logout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Color.fromARGB(255, 0, 1, 102),
              ),
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      Container(
                        alignment: Alignment.center,
                        child: Image(
                          image: AssetImage('assets/images/logo-ypc.png'),
                          height: 100,
                          width: 100,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          '${userData['name']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          '${userData['nisn']}',
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 1, 102),
                            fontSize: 22,
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      ListTile(
                        tileColor: Color.fromARGB(255, 0, 1, 102),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        title: Text(
                          'Data Diri',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          setState(() {
                            isDataDiriVisible = !isDataDiriVisible;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      isDataDiriVisible
                          ? Container(
                              padding: EdgeInsets.symmetric(horizontal: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 0, 1, 102),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userData['email']}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Username',
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 0, 1, 102),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userData['username']}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Kelas',
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 0, 1, 102),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userData['kelas']}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'No Telepon',
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 0, 1, 102),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userData['telp']}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Alamat',
                                    style: TextStyle(
                                        color: Color.fromARGB(255, 0, 1, 102),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${userData['alamat']}',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      SizedBox(height: 10),
                      ListTile(
                        tileColor: Color.fromARGB(255, 0, 1, 102),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        title: Text(
                          'Akun',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                        ),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => HalamanEditProfil(),
                          ));
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
