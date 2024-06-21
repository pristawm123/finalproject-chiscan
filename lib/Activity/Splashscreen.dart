// lib/splash_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prista_app/Activity/DeteksiPenyakitPage.dart';
import 'LoginPage.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Setelah 2 detik, cek status user
    Timer(Duration(seconds: 2), () {
      _checkLoginStatus();
    });
  }

  void _checkLoginStatus() async {
    String? loginStatus = await checkLoginStatus();
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    _navigateToNextScreen(loginStatus, userId ?? '');
  }

  Future<String?> checkLoginStatus() async {
    // Check Firebase authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in
      if (user.providerData
          .any((userInfo) => userInfo.providerId == 'google.com')) {
        return 'user_google'; // User logged in with Google Sign In
      } else {
        return null; // Unsupported login method (you can handle this case accordingly)
      }
    }
    return null; // User is not logged in
  }

  Future<void> _navigateToNextScreen(String? loginStatus, String userId) async {
    await Future.delayed(Duration(seconds: 2));

    if (loginStatus == 'user_google') {
      bool isUserRegistered = await checkUserRegistrationStatus(userId);

      if (isUserRegistered) {
        // Navigasi ke halaman DeteksiPenyakitPage karena pengguna menggunakan Google Sign In dan terdaftar sebagai user
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DeteksiPenyakitPage()),
        );
      } 
    } else {
      // Pengguna tidak terdaftar
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<bool> checkUserRegistrationStatus(String userId) async {
    try {
      // Mengakses Firestore collection 'Users' dan mencari dokumen dengan UID yang sesuai
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(userId)
          .get();

      // Mengecek apakah dokumen ditemukan (artinya UID ada di koleksi 'User')
      return userDoc.exists;
    } catch (error) {
      // Handle error
      print('Error checking user registration status: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Warna latar belakang splash screen
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gambar ikon cabai dari assets
            Image.asset(
              'assets/image/cabai.jpg', // Path ke gambar ikon cabai
              width: 100,
              height: 100,
              // Opsi lainnya seperti fit dan colorBlendMode dapat ditambahkan di sini
            ),
            SizedBox(height: 16),
            // Tambahkan teks atau elemen lainnya di sini
            Text(
              'Deteksi Penyakit Cabai',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
