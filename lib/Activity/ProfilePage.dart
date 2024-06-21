import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prista_app/Activity/EditProfil.dart';
import 'package:prista_app/Activity/LoginPage.dart';
import 'package:prista_app/Activity/TentangAplikasi.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email']);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

String _userName = '';
  String _userEmail = '';
  String _userPhoto = '';



  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userData = await _firestore.collection('User').doc(user.uid).get();
      setState(() {
        _userPhoto = userData.get('foto') ;
        _userName = userData.get('nama') ?? '';
        _userEmail = userData.get('email') ?? '';
      });
    }
  }

  Future<void> _confirmLogout() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Keluar',
            style: TextStyle(
              fontFamily: 'Poppins',
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Apakah Anda yakin ingin keluar?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tidak',
                style: TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Ya',
                style: TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await _handleLogout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    await Future.delayed(Duration(seconds: 2));

    Navigator.pop(context);
    await _auth.signOut();
    await googleSignIn.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _updateProfileData() async {
  final updatedData = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditProfilUser()),
  );

  if (updatedData != null && updatedData is Map<String, dynamic>) {
    setState(() {
      if (updatedData.containsKey('nama')) {
        _userName = updatedData['nama'];
      }
      if (updatedData.containsKey('foto')) {
        _userPhoto = updatedData['foto'];
      }
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: _userPhoto.isNotEmpty
                        ? Image.network(
                            _userPhoto,
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/image/profil.png',
                            width: 65,
                            height: 65,
                            fit: BoxFit.cover,
                          ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userName,
                            style: TextStyle(fontSize: 20),
                          ),
                          Text(
                            _userEmail,
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: _updateProfileData,
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TentangAplikasi()),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.info),
                      SizedBox(width: 8),
                      Text('Tentang Aplikasi',
                      style: TextStyle(
                        fontSize: 16
                      ),),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                InkWell(
                  onTap: _confirmLogout,
                  child: Row(
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text('Keluar',style: TextStyle(
                        fontSize: 16
                      ),),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
