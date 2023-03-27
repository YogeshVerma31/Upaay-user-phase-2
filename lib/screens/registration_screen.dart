import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app_one/constants/app_urls.dart';
import 'package:flutter_app_one/data_models/user.dart';
import 'package:flutter_app_one/utils/app_colors.dart';
import 'package:flutter_app_one/my_widgets/text_field.dart';
import 'package:flutter_app_one/screens/login_screen.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:http/http.dart';

import 'home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final cPassController = TextEditingController();
  final buildingController = TextEditingController();
  final areaController = TextEditingController();
  final wardController = TextEditingController();
  final pincodeController = TextEditingController();
  final cityController = TextEditingController();
  final aadharController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passController.dispose();
    cPassController.dispose();
    buildingController.dispose();
    areaController.dispose();
    wardController.dispose();
    pincodeController.dispose();
    cityController.dispose();
    aadharController.dispose();
    super.dispose();
  }

  late BuildContext dialogContext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Scaffold(
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.white,
                appBar: AppBar(
                  title: const Align(
                      alignment: Alignment(-0.25, 0.0),
                      child: Text(
                        "Register",
                        style: TextStyle(color: AppColors.appGrey),
                      )),
                  backgroundColor: Colors.white,
                  elevation: 0.0,
                  leading: IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.appGrey,
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const LoginScreen()),
                          (route) => false,
                        );
                      }),
                ),
                body: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(child: registrationForm())))
          ],
        ),
      ),
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const LoginScreen()),
        );
        return false;
      },
    ));
  }

  Container registrationForm() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 70.0),
        padding: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              heading('Full Name'),
              MyTextField(
                type: TextInputType.name,
                hint: "Enter your Name",
                key: null,
                myController: nameController,
              ),
              heading('Email'),
              MyTextField(
                type: TextInputType.emailAddress,
                hint: "Enter your email",
                key: null,
                myController: emailController,
              ),
              heading('Phone'),
              MyTextField(
                length: 10,
                type: TextInputType.phone,
                hint: "Enter your Phone Number",
                key: null,
                myController: phoneController,
              ),
              heading('Building'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your Building Name",
                key: null,
                myController: buildingController,
              ),
              heading('Area'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your Area",
                key: null,
                myController: areaController,
              ),
              heading('Ward'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your Ward",
                key: null,
                myController: wardController,
              ),
              heading('Pincode'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your Pincode",
                key: null,
                myController: pincodeController,
              ),
              heading('City'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your City",
                key: null,
                myController: cityController,
              ),
              heading('Aadhar Number'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your Aadhar Number",
                key: null,
                myController: aadharController,
              ),
              heading('Password'),
              MyTextField(
                hint: "Enter your password",
                isPassword: true,
                myController: passController,
              ),
              heading('Confirm Password'),
              MyTextField(
                hint: "Confirm password",
                isPassword: true,
                myController: cPassController,
              ),
              const SizedBox(
                height: 40.0,
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await register();
                },
                icon: Image.asset('assets/images/next_button.png'),
                iconSize: 40.0,
              )
            ]));
  }

  Padding heading(title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.appGrey,
        ),
      ),
    );
  }

  void showLoader(String text) {
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
                        child: Text(text),
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

  Future<void> register() async {
    String name = nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String pass = passController.text;
    String cpass = cPassController.text;
    String building = buildingController.text;
    String area = areaController.text;
    String ward = wardController.text;
    String pincode = pincodeController.text;
    String city = cityController.text;
    String aadhar = aadharController.text;

    if (email.isNotEmpty &&
        pass.isNotEmpty &&
        name.isNotEmpty &&
        phone.isNotEmpty &&
        cpass.isNotEmpty) {
      showLoader('Please wait...');
      final Response response = await post(
        Uri.parse(AppUrl.register),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "name": name,
          "email": email,
          "phone": phone,
          "building": building,
          "area": area,
          "ward": ward,
          "pincode": pincode,
          "city": city,
          "aadhar": aadhar,
          "cpassword": pass,
          "password": cpass
        }),
      );

      if (!(jsonDecode(response.body).toString().toLowerCase())
          .contains('data')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(jsonDecode(response.body).toString().toUpperCase()),
        ));
        Navigator.pop(dialogContext);
      } else {
        Navigator.pop(dialogContext);
        showLoader('Registration Successfull!\nLogging in.');
        final Response response = await post(
          Uri.parse(AppUrl.sendOtp),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{'email': email, 'password': pass}),
        );

        if (!(jsonDecode(response.body).toString().toLowerCase())
            .contains('data')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(jsonDecode(response.body).toString().toUpperCase()),
          ));
          Navigator.pop(dialogContext);
        } else {
          User user = User.fromJson(jsonDecode(response.body)['data']);

          UserPreferences userPreferences = UserPreferences();

          await userPreferences.saveUser(user);

          gotoHome();
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please enter valid email and password"),
      ));
    }
  }
}
