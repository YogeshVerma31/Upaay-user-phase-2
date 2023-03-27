// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    // ignore: missing_enum_constant_in_switch
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCS1Br3hRs4yM-2pUGtoS6ALO7Zqit9dBM',
    appId: '1:831620569905:web:251e2d1e52105a2b596e10',
    messagingSenderId: '831620569905',
    projectId: 'maljal-maljal',
    authDomain: 'maljal-maljal.firebaseapp.com',
    databaseURL: 'https://maljal-maljal-default-rtdb.firebaseio.com',
    storageBucket: 'maljal-maljal.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBQNXYZvkeF9KqJDMFUpIjhKXJDgiEOucs',
    appId: '1:831620569905:android:4f3f4b4b644beebf596e10',
    messagingSenderId: '831620569905',
    projectId: 'maljal-maljal',
    databaseURL: 'https://maljal-maljal-default-rtdb.firebaseio.com',
    storageBucket: 'maljal-maljal.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2DfMiJeXhAhS3T1E7bcJuxCOW2vt3Tis',
    appId: '1:831620569905:ios:7b27edbbd05c49a7596e10',
    messagingSenderId: '831620569905',
    projectId: 'maljal-maljal',
    databaseURL: 'https://maljal-maljal-default-rtdb.firebaseio.com',
    storageBucket: 'maljal-maljal.appspot.com',
    iosClientId: '831620569905-6d9iku7k19p379a0lf2gqr7plmnj8lc4.apps.googleusercontent.com',
    iosBundleId: '...',
  );
}
