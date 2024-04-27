import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:ujikom_jurnalprakerin/absensi.dart';
import 'package:ujikom_jurnalprakerin/kegiatan.dart';
import 'package:ujikom_jurnalprakerin/kehadiran.dart';
import 'package:ujikom_jurnalprakerin/home.dart';
import 'package:ujikom_jurnalprakerin/profil.dart';
import 'package:ujikom_jurnalprakerin/tabBar_view.dart';

class BottomNavigation extends StatefulWidget {
  int id;
  BottomNavigation({super.key, required this.id});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  var index = 0;
  @override
  void initState() {
    super.initState();
    setState(() {
      index = widget.id;
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black38)],
            color: Color.fromARGB(255, 0, 160, 234),
            borderRadius: BorderRadius.all(Radius.circular(40))),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SalomonBottomBar(
            selectedItemColor: Colors.white,
            unselectedItemColor: Color.fromARGB(255, 0, 1, 102),
            items: [
              SalomonBottomBarItem(
                icon: Icon(Icons.home),
                title: Text("Utama"),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.fingerprint),
                title: Text("Kehadiran"),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.list),
                title: Text("Kegiatan"),
              ),
              SalomonBottomBarItem(
                icon: Icon(Icons.settings),
                title: Text("Pengaturan"),
              )
            ],
            currentIndex: index,
            onTap: (selectedIndex) {
              setState(() {
                index = selectedIndex;
              });
            },
          ),
        ),
      ),
      body: Container(
          color: Colors.white, child: getSelectedWidget(index: index)),
    );
  }

  Widget getSelectedWidget({required int index}) {
    Widget widget;
    switch (index) {
      case 0:
        widget = const HalamanHome();
        break;
      case 1:
        widget = const TabBar_view();
        break;
      case 2:
        widget = const HalamanKegiatan();
        break;
      case 3:
        widget = const HalamanProfil();
        break;
      default:
        widget = const HalamanProfil();
    }
    return widget;
  }
}
