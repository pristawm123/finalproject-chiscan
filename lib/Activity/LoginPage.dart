import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'DeteksiPenyakitPage.dart'; 

class LoginPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Membuka dialog Google Sign-In
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      // Mengecek apakah pengguna berhasil memilih akun Google
      if (googleSignInAccount == null) {
        // User membatalkan login Google Sign-In
        return null;
      }

      // Mengautentikasi ke Firebase menggunakan Google Sign-In
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // SignIn dengan credential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      
      // Menyimpan data pengguna ke Firestore
      await _saveUserData(userCredential.user);

      // Menampilkan dialog progress
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Menunggu beberapa saat sebelum menutup dialog
      await Future.delayed(Duration(seconds: 2));
      Navigator.pop(context);

      // Redirect ke halaman yang sesuai
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DeteksiPenyakitPage()),
      );
      return userCredential;
    } catch (error) {
      // Handle error
      print('Error signing in with Google: $error');
      return null;
    }
  }

  Future<void> _saveUserData(User? user) async {
    if (user != null) {
      final userDoc = FirebaseFirestore.instance.collection('User').doc(user.uid);

      await userDoc.set({
        'email': user.email,
        'nama': user.displayName,
        'foto': '',
      });
    }
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/image/cabai.jpg',
              width: 100,
              height: 100,
            ),
            SizedBox(height: 16),
            Text(
              'Deteksi Penyakit Cabai',
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 100),
            Text(
              'Silahkan login terlebih dahulu untuk melanjutkan',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () async {
                await signInWithGoogle(context);
              },
              icon: Image.asset(
                'assets/image/icon_google.png',
                width: 35,
                height: 35,
              ),
              label: Text(
                'Masuk dengan Google',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.grey.shade300,
                minimumSize: Size(350, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
