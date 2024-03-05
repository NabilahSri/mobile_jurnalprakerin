import 'package:flutter/material.dart';
import 'package:ujikom_jurnalprakerin/absensi.dart';
import 'package:ujikom_jurnalprakerin/absensiPulang.dart';

class Tab_Bar extends StatefulWidget {
  const Tab_Bar({super.key});

  @override
  State<Tab_Bar> createState() => _Tab_BarState();
}

class _Tab_BarState extends State<Tab_Bar> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 0, 1, 102),
          title: Text(
            'Absensi',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        body: Column(
          children: [
            TabBar(
              indicatorColor: Color.fromARGB(255, 0, 1, 102).withOpacity(0.5),
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  child: Text(
                    'Masuk',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                ),
                Tab(
                  child: Text(
                    'Pulang',
                    style: TextStyle(color: Colors.grey, fontSize: 20),
                  ),
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                  children: [HalamanAbsensi(), HalamanAbsensiPulang()]),
            )
          ],
        ),
      ),
    );
  }
}
