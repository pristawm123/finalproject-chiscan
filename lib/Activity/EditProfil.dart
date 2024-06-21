import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilUser extends StatefulWidget {
  const EditProfilUser({Key? key}) : super(key: key);

  @override
  _EditProfilUserState createState() => _EditProfilUserState();
}

class _EditProfilUserState extends State<EditProfilUser> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String _userName;
  late String _userEmail;
  String _userPhoto = 'assets/image/profil.png'; // Default photo
  TextEditingController _namaController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  bool _isModified = false;

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
        _userPhoto = userData.get('foto') ?? 'assets/image/profil.png';
        _userName = userData.get('nama') ?? '';
        _userEmail = userData.get('email') ?? '';
        _namaController.text = _userName;
        _emailController.text = _userEmail;
      });
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  final picker = ImagePicker();
                  final XFile? image =
                      await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    _uploadImage(File(image.path));
                  }
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/image/kamera.png',
                      width: 40,
                      height: 40,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Ambil dari kamera',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  final XFile? imageFile =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (imageFile != null) {
                    _uploadImage(File(imageFile.path));
                  }
                },
                child: Row(
                  children: [
                    Image.asset(
                      'assets/image/galeri.png',
                      width: 40,
                      height: 40,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Ambil dari galeri',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImage(File imageFile) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // Jalur penyimpanan
        String filePath = 'foto_profil/${user.uid}.jpg';

        // Periksa apakah pengguna sudah memiliki gambar profil
        final userDoc = await _firestore.collection('User').doc(user.uid).get();
        String? oldPhotoUrl = userDoc.data()?['foto'];

        // Hapus gambar profil lama dari Firebase Storage jika ada
        if (oldPhotoUrl != null && oldPhotoUrl.isNotEmpty) {
          await FirebaseStorage.instance.refFromURL(oldPhotoUrl).delete();
        }

        // Unggah file baru ke Firebase Storage
        await FirebaseStorage.instance.ref(filePath).putFile(imageFile);

        // Dapatkan URL unduhan untuk gambar profil baru
        String downloadURL =
            await FirebaseStorage.instance.ref(filePath).getDownloadURL();

        // Perbarui URL foto pengguna di Firestore
        await _firestore.collection('User').doc(user.uid).update({
          'foto': downloadURL,
        });

        // Update foto profil pada halaman
        setState(() {
          _userPhoto = downloadURL;
        });

        Navigator.pop(context, downloadURL);

        // Pesan Berhasil
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Foto profil berhasil diperbarui',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Error uploading image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui foto profil')),
        );
      }
    }
  }


  Future<void> _showConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Dialog tidak bisa ditutup dengan mengetuk di luar dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi',
            style: TextStyle(fontFamily: 'Poppins'),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Apakah Anda ingin menyimpan perubahan?',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Tidak',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Ya',
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              onPressed: () {
                _updateUserData();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('User').doc(user.uid).update({
          'nama': _namaController.text,
        });

        setState(() {
          _userName = _namaController.text;
          _isModified = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil diperbarui')),
        );
      } catch (e) {
        print('Error updating user data: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(
            context,
            {'nama': _namaController.text, 'foto': _userPhoto},
          );
        },
      ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Implement your logic to update profile picture here
              },
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade600,
                          width: 2.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(60),
                        child: _userPhoto.isNotEmpty
                            ? Image.network(
                                _userPhoto,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/image/profil.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 5, bottom: 4),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.shade600,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        _showBottomSheet();
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 25),
            _buildTextField(
              hintText: 'Nama',
              prefixIcon: Icons.person,
              controller: _namaController,
              onChanged: (value) {
                setState(() {
                  _isModified = true;
                });
              },
            ),
            SizedBox(height: 20),
            _buildTextField(
              hintText: 'Email',
              prefixIcon: Icons.email,
              controller: _emailController,
              enabled: false,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isModified ? _showConfirmationDialog : null,
              child: Container(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Perbarui',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 97, 165, 68),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required IconData prefixIcon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    Function(String)? onChanged,
    Function()? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hintText + ' :',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 5),
        TextFormField(
          enabled: enabled,
          keyboardType: keyboardType,
          readOnly: !enabled,
          style: TextStyle(
            fontFamily: 'Poppins',
            color: enabled ? Colors.black : Colors.black,
          ),
          controller: controller,
          onChanged: onChanged,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF04558F)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF04558F)),
            ),
            // Menambahkan border meskipun form tidak dapat diedit
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFF04558F)),
            ),
          ),
        ),
      ],
    );
  }
}
