import 'package:flutter/material.dart';

class HalamanPengumuman extends StatefulWidget {
  final String pengumumanId;
  const HalamanPengumuman({super.key, required this.pengumumanId});

  @override
  State<HalamanPengumuman> createState() => _HalamanPengumumanState();
}

class _HalamanPengumumanState extends State<HalamanPengumuman> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('${widget.pengumumanId}'),
      ),
    );
  }
}
