import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:cross_file/cross_file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prista_app/Activity/DataPenyakitPage.dart';
import 'package:prista_app/Activity/ProfilePage.dart';
import 'package:prista_app/Activity/DetailTipsPage.dart';
import 'package:tflite_v2/tflite_v2.dart';

class DeteksiPenyakitPage extends StatefulWidget {
  const DeteksiPenyakitPage({Key? key}) : super(key: key);

  @override
  _DeteksiPenyakitPageState createState() => _DeteksiPenyakitPageState();
}

class _DeteksiPenyakitPageState extends State<DeteksiPenyakitPage> {
  int _selectedIndex = 0; // indeks untuk navigasi bawah

  // daftar halaman untuk navigasi bawah
  final List<Widget> _pages = [
    DeteksiPenyakitPageContent(),
    DataPenyakitPage(),
    ProfilePage(),
  ];

  // metode untuk menangani tap pada item navigasi bawah
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], //tampilkan halaman yang dipilih
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Data Penyakit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(226, 83, 122, 66),
        onTap: _onItemTapped,
      ),
    );
  }
}

// konten halaman deteksi penyakit
class DeteksiPenyakitPageContent extends StatefulWidget {
  const DeteksiPenyakitPageContent({Key? key}) : super(key: key);

  @override
  _DeteksiPenyakitPageContentState createState() =>
      _DeteksiPenyakitPageContentState();
}

class _DeteksiPenyakitPageContentState
    extends State<DeteksiPenyakitPageContent> {
  late CameraController _camController;
  String? pathDir;
  bool _showCamera = false;
  dynamic _predictionResult;
  String? userName;

  @override
  void initState() {
    super.initState();
    initCamera(); // inisialisasi kamera
    _fetchUserName(); // mengambil nama pengguna dari firebase
  }

  // metode untuk mengambil nama pengguna dari firebase

  Future<void> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();
      setState(() {
        userName = userDoc['nama'];
      });
    }
  }

  // metode untuk inisialisasi kamera
  Future<void> initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cameras = await availableCameras();
    _camController = CameraController(cameras[0], ResolutionPreset.high);
    await _camController.initialize();
    setState(() {});
    await Tflite.loadModel(
      model: 'assets/model.tflite',
      labels: 'assets/labels.txt',
    ).catchError((e) {
      log("Gagal memuat model: ${e.toString()}");
    });
  }

  // metode untuk mengambil gambar
  Future<String> takePicture() async {
    String filePath = "";
    try {
      XFile? img = await _camController.takePicture();
      filePath = img!.path;
      log("Gambar diambil: $filePath");
    } catch (e) {
      log("Kesalahan mengambil gambar: ${e.toString()}");
    }
    return filePath;
  }

  // metode digunakan untuk memprediksi gambar
  Future<void> predict(String path) async {
    try {
      var prediction = await Tflite.runModelOnImage(
        path: path,
        imageMean: 0.0,
        imageStd: 255.0,
        numResults: 3,
        threshold: 0.2,
        asynch: true,
      );

      log("Prediksi: $prediction");

      setState(() {
        _predictionResult = prediction;
      });
    } catch (e) {
      log("Kesalahan selama prediksi: ${e.toString()}");
    }
  }

// metode memilih gambar dari galeri
  Future<void> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      pathDir = image.path;
      await predict(pathDir!); // memproses gambar dan mendapatkan prediksi
      showModalBottomSheet(
        context: context,
        builder: (context) {
          if (_predictionResult == null || _predictionResult!.isEmpty) {
            return const Center(
              child: Text(
                "Tidak ada hasil prediksi.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }
          var predictionData = _predictionResult!;
          String label = predictionData[0]['label'];
          double confidence = predictionData[0]['confidence'];

          return Container(
            height: 400,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Hasil Pengecekan",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Confidence: ${confidence.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontFamily: "Poppins",
                  ),
                ),
                // const SizedBox(height: 20),
                // Align(
                //   alignment: Alignment.center,
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Navigator.pop(context);
                //     },
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor:
                //           const Color.fromARGB(255, 115, 183, 86), // Warna tombol
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(10),
                //       ),
                //     ),
                //     child: const Text(
                //       'Tutup',
                //       style: TextStyle(
                //         fontFamily: "Poppins",
                //         fontSize: 16,
                //         color: Colors.white,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _camController.dispose(); // hapus kontrol kamera saat tidak digunakan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: _showCamera
            ? const Text('') // Judul saat mode kamera aktif
            : Text(
                'Halo, ${userName ?? '...'}', // Nama pengguna atau teks default jika null
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
      ),
      body: Column(
        children: [
          // tampilkan teks sambutan jika kamera tidak aktif
          if (!_showCamera)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  children: [
                    Text(
                      'Selamat Datang di Chiscan',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Deteksi Penyakit Cabai',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // tampilkan tombol untuk masuk ke mode kamera jika kamera tdk aktif
          if (!_showCamera)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showCamera = true; // mengaktifkan mode kamera
                  });
                },
                child: Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 115, 183, 86), //warna tombol
                  ),
                  child: const Center(
                    child: Text(
                      'Masuk untuk Deteksi',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (_showCamera)
            Expanded(
              child: Stack(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 50),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height *
                              1 /
                              _camController.value.aspectRatio,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: CameraPreview(
                              _camController), // menampilkan pratinjau kamera
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (!_camController.value.isTakingPicture) {
                                pathDir = null;
                                pathDir =
                                    await takePicture(); // mengambil kamera
                                log("Path gambar: $pathDir");
                                if (pathDir != null) {
                                  await predict(
                                      pathDir!); // memproses gambar dan mendapatkan prediksi
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      if (_predictionResult == null ||
                                          _predictionResult.isEmpty) {
                                        return const Center(
                                          child: Text(
                                            "Tidak ada hasil prediksi.",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }
                                      var predictionData = _predictionResult!;
                                      String label = predictionData[0]['label'];
                                      double confidence =
                                          predictionData[0]['confidence'];

                                      return Container(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Hasil Pengecekan:",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                //kotak samping hasil
                                                // Container(
                                                //   width: 60,
                                                //   height: 60,
                                                //   decoration: BoxDecoration(
                                                //     color: Colors.grey[200],
                                                //     borderRadius:
                                                //         BorderRadius.circular(
                                                //             10),
                                                //   ),
                                                // ),
                                                const SizedBox(width: 20),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        label,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        "Confidence: ${confidence.toStringAsFixed(2)}",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  log("Path gambar null");
                                }
                              }
                            },
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(255, 115, 183,
                                    86), //warna latar belakang tombol
                              ),
                              child: const Center(
                                child: Text(
                                  "Scan",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                pickImageFromGallery, // memilih gambar dari galeri
                            child: Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: const Color.fromARGB(255, 115, 183,
                                    86), // warna latar belakang tombol
                              ),
                              child: const Center(
                                child: Text(
                                  "Galeri",
                                  style: TextStyle(
                                    fontFamily: "Poppins",
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _showCamera = false; // menonaktifkan mode kamera
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                ],
              ),
            ),
          if (!_showCamera)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Tips Pengelolaan',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (!_showCamera)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future:
                    _fetchDataTips(), // mendapatkan data tips secara asinkron
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child:
                            CircularProgressIndicator()); // menampilkan loading jika data belum selesai diambil
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error: ${snapshot.error}')); // menampilkan pesan eror jika terjadi kesalahan
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                            'No data available')); //menampilkan pesan jika data kosong
                  } else {
                    List<Map<String, dynamic>> daftarTips = snapshot.data!;
                    return ListView.builder(
                      itemCount: daftarTips.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              top: 2, right: 8, left: 8, bottom: 8),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailTipsPage(
                                    judulTips: daftarTips[index]['judul'],
                                    gambarUrl: daftarTips[index]['gambarUrl'],
                                    deskripsi: daftarTips[index]['deskripsi'],
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Detail tips
                                    Text(
                                      daftarTips[index]
                                          ['judul'], // menampilkan judul tips
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 150, // Tinggi gambar
                                      width: double
                                          .infinity, // Lebar gambar mengikuti lebar layar
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: AssetImage(
                                            daftarTips[index]['gambarUrl'],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Klik untuk melihat detail',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
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
            ),
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDataTips() async {
    List<Map<String, dynamic>> daftarTips = [];
    CollectionReference dataTips =
        FirebaseFirestore.instance.collection('data_tips');

    QuerySnapshot querySnapshot = await dataTips.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      // Ambil data dari Firestore
      String judulTips = data['judul'] ?? '';
      String deskripsi =
          data['deskripsi'] ?? ''; // Ubah tipe data deskripsi menjadi String

      // Tentukan alamat gambar berdasarkan judul artikel atau jenis artikel
      String imagePath;
      if (judulTips == 'Benih dan Persemaian') {
        imagePath = 'assets/image/3.png';
      } else if (judulTips == 'Pengolahan Tanah') {
        imagePath = 'assets/image/4.png';
      } else {
        // Default jika judul artikel tidak cocok dengan yang ditentukan
        imagePath = 'assets/image/default_image.jpg';
      }

      daftarTips.add({
        'judul': judulTips,
        'gambarUrl': imagePath,
        'deskripsi': deskripsi,
      });
    }
    return daftarTips;
  }
} 