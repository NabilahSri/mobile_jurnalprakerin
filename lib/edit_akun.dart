import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ujikom_jurnalprakerin/bottom_navigation.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_error.dart';
import 'package:ujikom_jurnalprakerin/custom_snackbar_success.dart';
import 'package:ujikom_jurnalprakerin/koneksi.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:ujikom_jurnalprakerin/profil.dart';

class HalamanEditAkun extends StatefulWidget {
  const HalamanEditAkun({super.key});

  @override
  State<HalamanEditAkun> createState() => _HalamanEditProfilState();
}

class _HalamanEditProfilState extends State<HalamanEditAkun> {
  bool _isLoading = false;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  Map<String, dynamic> userData = {};
  Future<void> fetchData() async {
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
          usernameController.text = userData['username'];
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
  }

  Future<void> editData() async {
    setState(() {
      _isLoading = true;
    });
    SharedPreferences shared = await SharedPreferences.getInstance();
    String? userId = shared.getString('id');
    String? token = shared.getString('token');

    final response = await http.post(
      Uri.parse(koneksi().baseUrl + 'auth/edit/$userId?token=$token'),
      body: jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      }),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        CustomSnackBarSuccess.show(context, 'Data berhasil diupdate.');
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => BottomNavigation(id: 3),
        ));
      } else {
        CustomSnackBarError.show(context, 'Data gagal diupdate!');
      }
    } else {
      CustomSnackBarError.show(context, 'Tidak boleh ada data yang kosong!');
    }
    setState(() {
      _isLoading = false;
    });
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
            backgroundColor: Color.fromARGB(255, 0, 160, 234),
            title: Text(
              'Edit Akun',
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
                    keyboardType: TextInputType.text,
                    controller: usernameController,
                    onChanged: (value) {
                      usernameController.text = value;
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                  ),
                ),
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
                    keyboardType: TextInputType.text,
                    obscureText: true,
                    onChanged: (value) {
                      passwordController.text = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Masukan kata sandi jika ingin di ubah",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                InkWell(
                  onTap: () {
                    editData();
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
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Simpan Perubahan',
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
