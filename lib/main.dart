import 'package:flutter/material.dart';
import 'package:prista_app/Activity/Splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyCJxrAD4KisFuzaYyT2-SQI5JmEHGY5cBk',
          appId: '1:552220718106:android:3ab9c7945e8665fa0d8da3',
          messagingSenderId: '552220718106',
          projectId: 'pristaapp-32731'));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Prista Apps',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

