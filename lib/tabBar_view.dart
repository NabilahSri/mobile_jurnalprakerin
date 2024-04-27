import 'package:flutter/material.dart';
import 'package:ujikom_jurnalprakerin/absensi.dart';
import 'package:ujikom_jurnalprakerin/absensiPulang.dart';
import 'package:ujikom_jurnalprakerin/history.dart';
import 'package:ujikom_jurnalprakerin/kehadiran.dart';

class TabBar_view extends StatelessWidget {
  const TabBar_view({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
              backgroundColor: Color.fromARGB(253, 3, 146, 213),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Absensi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert),
                    offset: Offset(0.0, 55.0),
                    itemBuilder: (ctx) => [
                      _buildPopupMenuItem("Histori Kehadiran", context),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Color.fromARGB(255, 1, 101, 147).withOpacity(0.5)),
                  child: const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: Color.fromARGB(255, 1, 101, 147),
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87,
                    tabs: [
                      Tab(
                        child: Text('Masuk'),
                      ),
                      Tab(
                        child: Text('Pulang'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: const TabBarView(
                  children: [HalamanAbsensi(), HalamanAbsensiPulang()],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

PopupMenuItem _buildPopupMenuItem(String title, BuildContext context) {
  return PopupMenuItem(
    child: Container(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => HalamanHistory()),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text(title)],
        ),
      ),
    ),
  );
}
