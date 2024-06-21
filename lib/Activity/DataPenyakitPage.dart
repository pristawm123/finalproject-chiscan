import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'DetailPenyakit.dart';

class DataPenyakitPage extends StatelessWidget {
  Future<List<Map<String, dynamic>>> _fetchDataPenyakit() async {
    List<Map<String, dynamic>> daftarPenyakit = [];
    CollectionReference dataPenyakit =
        FirebaseFirestore.instance.collection('data_penyakit');

    QuerySnapshot querySnapshot = await dataPenyakit.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Ambil data dari Firestore
      String namaPenyakit = data['name'] ?? '';
      List<dynamic> ciriCiri = data['ciri_ciri'] ?? [];
      List<dynamic> penanganan = data['penanganan'] ?? [];

      // Tentukan alamat gambar berdasarkan nama penyakit
      String imagePath;
      if (namaPenyakit == 'Penyakit Bercak') {
        imagePath = 'assets/image/penyakit_bercak.jpg';
      } else if (namaPenyakit == 'Penyakit Virus Kuning') {
        imagePath = 'assets/image/penyakit_kuning.jpg';
      } else if (namaPenyakit == 'Penyakit Layu Fusarium') {
        imagePath = 'assets/image/layu_fusarium.jpg';
      } else {
        // Default jika nama penyakit tidak cocok dengan yang ditentukan
        imagePath = 'assets/image/default_image.jpg';
      }

      daftarPenyakit.add({
        'nama': namaPenyakit,
        'gambarUrl': imagePath,
        'ciriCiri': ciriCiri,
        'penanganan': penanganan,
      });
    }
    return daftarPenyakit;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Penyakit', style: 
        TextStyle(
          fontWeight: FontWeight.bold
        ),),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDataPenyakit(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No data available'));
          } else {
            List<Map<String, dynamic>> daftarPenyakit = snapshot.data!;
            return ListView.builder(
              itemCount: daftarPenyakit.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(top: 2, right: 8, left: 8, bottom: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPenyakitPage(
                            namaPenyakit: daftarPenyakit[index]['nama'],
                            gambarUrl: daftarPenyakit[index]['gambarUrl'],
                            ciriCiri: daftarPenyakit[index]['ciriCiri'],
                            penanganan: daftarPenyakit[index]['penanganan'],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            // Gambar penyakit
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: AssetImage(
                                daftarPenyakit[index]['gambarUrl'],
                              ),
                            ),
                            SizedBox(width: 10),
                            // Detail penyakit
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  daftarPenyakit[index]['nama'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Klik untuk melihat detail',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
