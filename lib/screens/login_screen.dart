import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_one/constants/app_urls.dart';
import 'package:flutter_app_one/data_models/user.dart';
import 'package:flutter_app_one/my_widgets/app_button.dart';
import 'package:flutter_app_one/my_widgets/text_field.dart';
import 'package:flutter_app_one/screens/book_track_screen.dart';
import 'package:flutter_app_one/screens/profile_screen.dart';
import 'package:flutter_app_one/screens/registration_screen.dart';
import 'package:flutter_app_one/utils/app_colors.dart';
import 'package:flutter_app_one/utils/network_connecttion.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:flutter_app_one/utils/globals.dart' as globals;
import 'package:location/location.dart';
import 'package:sms_autofill/sms_autofill.dart';

import 'book_service.dart';
import 'booking_history.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Timer? timer;
  LatLng latLng = const LatLng(0, 0);

  late String _phone, _otp;
  final phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool showOTP = false;
  String appSignature = 'qsyJENrq9bU';

  @override
  void initState() {
    super.initState();
    SmsAutoFill().getAppSignature.then((value) {
      appSignature = value;
    });
    WidgetsBinding.instance?.addPostFrameCallback((_) => getCurrentLocation());
  }

  @override
  void dispose() {
    if (timer != null) {
      timer!.cancel();
    }
    SmsAutoFill().unregisterListener();
    otpController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  late BuildContext dialogContext, exitDialogContext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        if (showOTP) {
          showAlertDialog();
        } else {
          SystemNavigator.pop();
        }
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              color: AppColors.backgroundcolor,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(children: [
                Image.asset('assets/images/login_bg_i.png'),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: (showOTP ? getOTPLayout() : getphoneNumberLayout()),
                )
              ]),
            ),
          ],
        ),
      ),
    ));
  }

  getphoneNumberLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          height: 30,
        ),
        Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: 210.0,
          ),
        ),
        const SizedBox(height: 60.0),
        const Padding(
          padding: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 20.0),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Enter Your Phone Number',
                  style: TextStyle(
                      color: AppColors.lightTextColor, fontSize: 18))),
        ),
        MyTextField(
          myController: phoneController,
          type: TextInputType.phone,
          length: 10,
          prefix: '    +91  ',
          hint: 'Phone Number',
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: AppButton(
            width: 150,
            title: 'LET\'S START',
            onPressed: () async {
              NetworkCheckUp().checkConnection().then((value) {
                if (value) {
                  SmsAutoFill().listenForCode;
                  sendOTP();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please connect to internet."),
                  ));
                }
              });
            },
          ),
        ),
        /* Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            
            icon: Image.asset('assets/images/continue_button.png'),
            iconSize: 150.0,
          ),
        ), */
        GestureDetector(
          onTap: gotoHome,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'SKIP',
                style:
                    TextStyle(fontSize: 18, color: AppColors.buttonGradientTop),
              ),
              Icon(
                Icons.double_arrow,
                color: AppColors.appGreen,
              ),
            ],
          ),
        ),
        /* Center(
          child: TextButton(
            onPressed: gotoHome,
            child: const Text('SKIP'),
          ),
        ), */
      ],
    );
  }

  getOTPLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(
          height: 30,
        ),
        Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: 210.0,
          ),
        ),
        const SizedBox(height: 60.0),
        const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Enter the OTP',
              style: TextStyle(fontSize: 18, color: AppColors.lightTextColor),
            )),
        Row(
          children: <Widget>[
            Text(
              'sent to ${phoneController.text}',
              style: const TextStyle(color: AppColors.lightTextColor),
            ),
            TextButton(
                onPressed: () {
                  showAlertDialog();
                },
                child: const Text(
                  'change?',
                  style: TextStyle(decoration: TextDecoration.underline),
                ))
          ],
        ),
        PinFieldAutoFill(
          decoration: const UnderlineDecoration(
              textStyle: TextStyle(color: AppColors.lightTextColor),
              colorBuilder: FixedColorBuilder(AppColors.appGreen)),
          controller: otpController,
          codeLength: 6,
          onCodeSubmitted: (code) {
            _otp = code;
            doLogin();
          },
          onCodeChanged: (code) {
            if (code!.length == 6) {
              _otp = code;
              doLogin();
            }
          },
        ),
        const SizedBox(
          height: 20,
        ),
        StatefulBuilder(builder: (BuildContext context, StateSetter setter) {
          timer = Timer(const Duration(seconds: 1), () {
            getTimeText(setter);
          });
          return Text(timeText);
        }),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 100),
          child: TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: AppColors.buttonGradientBottom,
                  minimumSize: const Size(150, 40)),
              child: const Icon(
                Icons.arrow_right_alt,
                color: Colors.white,
              ),
              onPressed: () {
                NetworkCheckUp().checkConnection().then((value) {
                  if (value) {
                    doLogin();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please connect to internet."),
                    ));
                  }
                });
              }),
        ),
        /* Center(
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            ,
            icon: Image.asset('assets/images/next_button.png'),
            iconSize: 150.0,
          ),
        ), */
      ],
    );
  }

  int startTime = 120;
  String timeText = 'Resend OTP in 2 : 00';

  getTimeText(setter) async {
    if (startTime != 0) {
      setter(() {
        startTime = (startTime - 1).round();
        if (startTime >= 60) {
          timeText = 'Resend OTP in 1 : ' + (startTime - 60).toString();
        } else {
          timeText = 'Resend OTP in 0 : ' + startTime.toString();
        }
      });
    } else {
      await SmsAutoFill().unregisterListener();
      sendOTP();
    }
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
                    children: <Widget>[
                      const CircularProgressIndicator(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: (showOTP
                            ? const Text('Please wait while we login...')
                            : const Text('Please wait...')),
                      ),
                    ],
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
  }

  showAlertDialog() {
    // set up the buttons
    Widget yesButton = TextButton(
      child: const Text("YES"),
      onPressed: () {
        timer!.cancel();
        showOTP = !showOTP;
        setState(() {
          //await _controller.pause();
          Navigator.pop(exitDialogContext);
        });
      },
    );
    Widget noButton = TextButton(
      child: const Text("NO"),
      onPressed: () {
        Navigator.pop(exitDialogContext);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("AlertDialog"),
      content: const Text("Are you sure?"),
      actions: [
        yesButton,
        noButton,
      ],
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        exitDialogContext = context;
        return WillPopScope(
            child: alert,
            onWillPop: () async {
              return false;
            });
      },
    );
  }

  void showExitDialog() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          exitDialogContext = context;
          return WillPopScope(
              child: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text('Are you sure?'),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: GestureDetector(
                              child: const Text('YES'),
                              onTap: () {
                                setState(() {
                                  timer!.cancel();
                                  showOTP = !showOTP;
                                  Navigator.pop(exitDialogContext);
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: GestureDetector(
                              child: const Text('NO'),
                              onTap: () {
                                Navigator.pop(exitDialogContext);
                              },
                            ),
                          )
                        ],
                      )
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

  void gotoBookTrack() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const BookTrackScreen()));
  }

  void gotoRegistrations() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => const RegistrationScreen()));
  }

  Future<void> sendOTP() async {
    try {
      _phone = phoneController.text;
      //_password = passwordController.text;

      if (_phone.length == 10) {
        showLoader();
        final Response response = await post(
          Uri.parse(AppUrl.sendOtp),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(
              <String, String>{'phone': _phone, 'signature': appSignature}),
        );

        log(response.body);
        if (!(jsonDecode(response.body).toString().toLowerCase())
            .contains('success')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(jsonDecode(response.body).toString().toUpperCase()),
          ));
          Navigator.pop(dialogContext);
        } else {
          setState(() {
            startTime = 120;
            SmsAutoFill().listenForCode;
            showOTP = true;

            Navigator.pop(dialogContext);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a valid Phone Number."),
        ));
      }
    } catch (e) {
      Navigator.pop(dialogContext);
      log(e.toString());
    }
  }

  Future<void> doLogin() async {
    try {
      _otp = otpController.text;
      log('_otp: ' + _otp);

      if (_otp.length == 6) {
        showLoader();
        final Response response = await post(
          Uri.parse(AppUrl.verifyOtp),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{'phone': _phone, 'otp': _otp}),
        );

        log(response.body);
        if (!(jsonDecode(response.body).toString().toLowerCase())
            .contains('success')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                jsonDecode(response.body)['message'].toString().toUpperCase()),
          ));
          Navigator.pop(dialogContext);
        } else {
          dispose();
          timer!.cancel();

          User user = User.fromJson(jsonDecode(response.body)['data']);

          UserPreferences userPreferences = UserPreferences();

          await userPreferences.saveUser(user);

          checkPath();
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter a valid details."),
        ));
      }
    } catch (e) {
      log(e.toString());
    }
  }

  checkPath() {
    if (globals.gotoBookingHistory) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const BookingHistoryScreen(login: true)));
    } else if (globals.gotoProfile) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const ProfileScreen(login: true)));
    } else if (globals.gotoBookService) {
      var item = globals.item;
      if (item != null) {
        /* Navigator.pushReplacement(
            context, */
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => BookServiceScreen(
                  depId: depId,
                  serviceName: item.title,
                  vibhag: item.vibhag,
                  serviceId: item.id,
                  login: true)),
          (route) => false,
        );
        /* MaterialPageRoute(
                builder: (context) => BookServiceScreen(
                      depId: depId,
                      serviceName: item.title,
                      vibhag: item.vibhag,
                      serviceId: item.id,
                    ))); */
      }
    } else {
      gotoHome();
    }
    clearGlobals();
  }

  clearGlobals() {
    globals.depId = -1;
    globals.item;
    globals.gotoBookService = false;
    globals.gotoBookingHistory = false;
    globals.gotoProfile = false;
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
