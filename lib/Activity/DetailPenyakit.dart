import 'package:flutter/material.dart';

class DetailPenyakitPage extends StatelessWidget {
  final String namaPenyakit;
  final String gambarUrl;
  final List<dynamic> ciriCiri;
  final List<dynamic> penanganan;

  DetailPenyakitPage({
    required this.namaPenyakit,
    required this.gambarUrl,
    required this.ciriCiri,
    required this.penanganan,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          namaPenyakit,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Image.asset(gambarUrl),
              ),
            ),
            SizedBox(height: 16),
            // Ciri-ciri penyakit
            Text(
              'Ciri-ciri:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: ciriCiri.map((ciri) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text('- $ciri', style: TextStyle(fontSize: 16)),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            // Penanganan penyakit
            Text(
              'Penanganan:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: penanganan.map((penanganan) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text('- $penanganan', style: TextStyle(fontSize: 16)),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
