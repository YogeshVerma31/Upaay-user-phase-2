import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app_one/screens/splash_screen.dart';
// ignore: unused_import
import 'package:flutter_app_one/screens/tracker_screen.dart';
import 'package:flutter_app_one/utils/app_colors.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

/* void main() {
  runApp(const MyApp());
} */

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        //fontFamily: 'Amsi',
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.backgroundcolor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MySplashScreen(),
      //home: const MarkLocationScreen(),
    );
  }
}
