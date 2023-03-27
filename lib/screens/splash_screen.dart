import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_one/screens/book_track_screen.dart';
import 'package:flutter_app_one/screens/home_screen.dart';
import 'package:flutter_app_one/screens/welcome_screen.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'login_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  LatLng latLng = const LatLng(0, 0);
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () => checkLogin());
    WidgetsBinding.instance?.addPostFrameCallback((_) => getCurrentLocation());
  }

  getCurrentLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    double? lat = _locationData.latitude;
    double? lng = _locationData.longitude;
    latLng = LatLng(lat ?? 0, lng ?? 0);

    await UserPreferences().setLocation(lat.toString(), lng.toString());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Material(
            child: Container(
                color: const Color(0xffEBF8FF),
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        top: 75,
                        left: 75,
                        right: 75,
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 250,
                        )),
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Image.asset('assets/images/splash_bg.png')),
                  ],
                ))));
  }

  /* Future<void> checkLogin() async {
    // ignore: unused_local_variable
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('showError').get();
    if (snapshot.exists) {
      var showError = snapshot.value;
      if (showError == true) {
        //log(snapshot.value.toString());
        showLoader();
      } else {
        UserPreferences userPreferences = UserPreferences();
        String token = (await userPreferences.getUser()).token;
        if (!await userPreferences.getWelcomeScreenStatus()) {
          gotoWelcome();
        } else if (token != '') {
          gotoBookTrack();
        } else {
          gotoLogin();
        }
      }
    } else {
      log('No data available.');
    }
  } */

  checkLogin() async {
    UserPreferences userPreferences = UserPreferences();
    String token = (await userPreferences.getUser()).token;
    if (token != '') {
      gotoHome();
    } else {
      gotoLogin();
    }
  }

  gotoBookTrack() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const BookTrackScreen()));
  }

  gotoHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  gotoWelcome() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()));
  }

  gotoLogin() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void showLoader() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return WillPopScope(
              child: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text('Please contact the app developer...'),
                      ),
                    ],
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
  }
}
