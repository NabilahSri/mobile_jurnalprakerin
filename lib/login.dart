import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom_jurnalprakerin/bottom_navigation.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_error.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_success.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_warning.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';
import 'package:http/http.dart' as http;

class HalamanLogin extends StatefulWidget {
  const HalamanLogin({super.key});

  @override
  State<HalamanLogin> createState() => _HalamanLoginState();
}

class _HalamanLoginState extends State<HalamanLogin> {
  bool _isLoading = false;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final response = await http.post(
      Uri.parse(koneksi().baseUrl + 'auth/login'),
      body: {
        'username': usernameController.text,
        'password': passwordController.text,
      },
    );
    log(response.body);
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final user = responseData['user'];
      final siswa = responseData['siswa'];
      final token = responseData['token'];
      final id = user['id'].toString();
      final level = user['level'].toString();

      if (level == 'siswa') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        final id_siswa = siswa['id'].toString();
        final id_kelas = siswa['kelas']['id'].toString();
        await prefs.setString('token', token);
        await prefs.setString('id', id);
        await prefs.setString('id_siswa', id_siswa);
        await prefs.setString('id_kelas', id_kelas);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => BottomNavigation(id: 0),
            ),
            (route) => false);
      } else {
        CustomSnackBarWarning.show(context, 'Anda tidak memiliki hak akses!');
      }
    } else {
      CustomSnackBarError.show(context, 'Username atau password tidak sesuai');
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  child: Image(
                    image: AssetImage('assets/images/logo-ypc.png'),
                    height: 150,
                    width: 150,
                  ),
                ),
                Container(
                  child: Text(
                    'Jurnal Prakerin',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 1, 102),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  alignment: Alignment.center,
                ),
                SizedBox(height: 50),
                //inputNISN
                Container(
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
                      ]),
                  child: TextFormField(
                    controller: usernameController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: "Username",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                //inputPassword
                SizedBox(height: 15),
                Container(
                  height: 55,
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
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Kata Sandi",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                InkWell(
                  onTap: () {
                    login(context);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 0, 160, 234),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        )
                      ],
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            'Masuk',
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
