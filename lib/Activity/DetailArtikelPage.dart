import 'package:flutter/material.dart';

class DetailArtikelPage extends StatelessWidget {
  final String judulArtikel;
  final String gambarUrl;
  final String deskripsi; // Ubah tipe data deskripsi menjadi String

  DetailArtikelPage({
    required this.judulArtikel,
    required this.gambarUrl,
    required this.deskripsi,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          judulArtikel,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 115, 183, 86), // Warna AppBar
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                width: double.infinity,
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10), // Membuat gambar memiliki sudut membulat
                  child: Image.asset(
                    gambarUrl,
                    fit: BoxFit.cover, // Menyesuaikan gambar agar sesuai dengan ukuran kontainer
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              judulArtikel,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              color: Colors.grey[400],
              thickness: 1.5,
              height: 32,
            ),
            Text(
              deskripsi,
              style: TextStyle(
                fontSize: 16,
                height: 1.5, // Menambah jarak antar baris teks untuk kemudahan membaca
              ),
            ),
          ],
        ),
      ),
    );
  }
}
