import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:ujikom_jurnalprakerin/kehadiran.dart';
import 'package:ujikom_jurnalprakerin/home.dart';
import 'package:ujikom_jurnalprakerin/profil.dart';

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
      backgroundColor: Colors.white,
      bottomNavigationBar: SalomonBottomBar(
        margin: EdgeInsets.all(18),
        items: [
          SalomonBottomBarItem(
              icon: Icon(Icons.home),
              title: Text("Utama"),
              selectedColor: Color.fromARGB(255, 0, 1, 102)),
          SalomonBottomBarItem(
              icon: Icon(Icons.fingerprint),
              title: Text("Kehadiran"),
              selectedColor: Color.fromARGB(255, 0, 1, 102)),
          SalomonBottomBarItem(
              icon: Icon(Icons.people),
              title: Text("Profil"),
              selectedColor: Color.fromARGB(255, 0, 1, 102))
        ],
        currentIndex: index,
        onTap: (selectedIndex) {
          setState(() {
            index = selectedIndex;
          });
        },
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
        widget = const HalamanKehadiran();
        break;
      case 2:
        widget = const HalamanProfil();
        break;
      default:
        widget = const HalamanHome();
    }
    return widget;
  }
}