import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_one/my_widgets/app_button.dart';
import 'package:flutter_app_one/screens/registration_screen.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'booking_history.dart';
import 'home_screen.dart';

class BookTrackScreen extends StatefulWidget {
  const BookTrackScreen({Key? key}) : super(key: key);

  @override
  _BookTrackScreenState createState() => _BookTrackScreenState();
}

class _BookTrackScreenState extends State<BookTrackScreen> {
  LatLng latLng = const LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => getCurrentLocation());
  }

  @override
  void dispose() {
    super.dispose();
  }

  late BuildContext dialogContext;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: SafeArea(
          child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/images/login_bg.png'),
            fit: BoxFit.cover,
          )),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                  child: Column(
                children: <Widget>[
                  Image.asset(
                    'assets/images/logo.png',
                    width: 210.0,
                  ),
                  const SizedBox(
                    height: 80.0,
                  ),
                  AppButton(
                      title: 'BOOK A SERVICE',
                      width: 200.0,
                      onPressed: gotoHome),
                  const SizedBox(
                    height: 40.0,
                  ),
                  AppButton(
                      title: 'TRACK A SERVICE',
                      width: 200.0,
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const BookingHistoryScreen()));
                      }),
                ],
              ))
            ],
          ),
        ),
      )),
    );
  }

  void showLoader() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      CircularProgressIndicator(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text('Please wait while we login...'),
                      ),
                    ],
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
  }

  void gotoHome() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  void gotoRegistrations() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const RegistrationScreen()));
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
}
