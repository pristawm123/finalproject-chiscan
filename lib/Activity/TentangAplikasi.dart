import 'package:flutter/material.dart';

class TentangAplikasi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang Aplikasi',
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat datang di Aplikasi Deteksi Penyakit Cabai!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Aplikasi Deteksi Penyakit Cabai adalah solusi inovatif untuk para petani cabai yang ingin memastikan kesehatan tanaman mereka dengan lebih efektif. Dengan teknologi canggih yang ditanamkan dalam aplikasi ini, para petani dapat dengan mudah dan cepat mendeteksi serta mengatasi berbagai penyakit yang mungkin menyerang tanaman cabai mereka.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Fitur Utama:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '1. Deteksi Penyakit:',
                style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.bold),
              ),
              Text(
                'Aplikasi akan menganalisis gambar tanaman cabai Anda yang memberikan diagnosis yang cepat dan akurat mengenai penyakit yang mungkin ada. Dengan hanya mengambil foto tanaman cabai, Anda dapat mengetahui apakah tanaman Anda terinfeksi penyakit dan jenis penyakit apa yang sedang dialami.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '2. Informasi Penyakit Cabai:',
                style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.bold),
              ),
              Text(
                'Aplikasi menyediakan informasi lengkap mengenai berbagai jenis penyakit yang umumnya menyerang tanaman cabai. Setiap penyakit dilengkapi dengan ciri-ciri khasnya dan metode penanganan yang disarankan.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Aplikasi Deteksi Penyakit Cabai ini dirancang untuk mempermudah para petani dalam merawat tanaman cabai mereka dengan lebih efisien. Kami berkomitmen untuk terus meningkatkan kualitas aplikasi ini demi memberikan pengalaman yang lebih baik bagi para pengguna.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                'Terima kasih telah memilih Aplikasi Deteksi Penyakit Cabai sebagai mitra Anda dalam mengelola kebun cabai Anda. Jika Anda memiliki pertanyaan atau masukan, jangan ragu untuk menghubungi tim dukungan kami. Selamat berkebun dan semoga panen cabai Anda berlimpah!',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
