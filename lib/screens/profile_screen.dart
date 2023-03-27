import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app_one/constants/app_urls.dart';
import 'package:flutter_app_one/data_models/areas.dart';
import 'package:flutter_app_one/data_models/cities.dart';
import 'package:flutter_app_one/my_widgets/app_button.dart';
import 'package:flutter_app_one/my_widgets/text_field.dart';
import 'package:flutter_app_one/utils/app_colors.dart';
import 'package:flutter_app_one/utils/network_connecttion.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:http/http.dart';

import '../data_models/user.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool? login;
  const ProfileScreen({Key? key, this.login}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '-';
  String email = '-';
  String building = '-';
  String ward = '-';
  String aadhar = '-';

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final aadharController = TextEditingController();
  final buildingController = TextEditingController();
  final areaController = TextEditingController();
  final wardController = TextEditingController();
  final pincodeController = TextEditingController();
  final cityController = TextEditingController();

  String cityText = 'Select City';
  String cityId = '0';
  String areaId = '0';
  String areaText = 'Select Area';
  String pincodeText = 'Pincode';

  List<Cities> cities = [];
  List<Areas> areas = [];

  late BuildContext listDialogContext, waitDialogContext;
  late BuildContext buildContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => getUserInfo());
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    buildingController.dispose();
    wardController.dispose();
    aadharController.dispose();
    super.dispose();
  }

  late BuildContext dialogContext;

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return SafeArea(
        child: WillPopScope(
            onWillPop: () async {
              if (widget.login != null && widget.login == true) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const HomeScreen()),
                  (route) => false,
                );
              } else {
                Navigator.pop(context);
              }
              /* Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const HomeScreen()),
                (route) => false,
              ); */
              return false;
            },
            child: Scaffold(
                appBar: AppBar(
                  title: const Align(
                      alignment: Alignment(-0.25, 0.0),
                      child: Text(
                        "Profile",
                        style: TextStyle(color: AppColors.appTextDarkBlue),
                      )),
                  backgroundColor: AppColors.backgroundcolor,
                  elevation: 0,
                  leading: IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.appGrey,
                      ),
                      onPressed: () {
                        if (widget.login != null && widget.login == true) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const HomeScreen()),
                            (route) => false,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                        /* Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const HomeScreen()),
                          (route) => false,
                        ); */
                      }),
                ),
                body: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(
                        child: Container(
                      child: registrationForm(),
                    ))))));
  }

  getUserInfo() async {
    try {
      showLoader('Please wait...');
      String token = '';
      await UserPreferences().getToken().then((value) => {token = value});

      final Response response = await get(
        Uri.parse(AppUrl.updateUser),
        headers: <String, String>{'token': token},
      );
      if (response.statusCode == 200) {
        User user = User.fromJson(jsonDecode(response.body)['data']);

        setState(() {
          nameController.text = user.name;
          emailController.text = user.email;
          buildingController.text = user.building;

          areaId = user.areaId;
          areaText = user.areaId != '0' ? user.areaName : areaText;

          wardController.text = user.ward;

          cityId = user.cityId;
          cityText = user.cityId != '0' ? user.cityName : cityText;

          pincodeText = user.pincode != '0' ? user.pincode : pincodeText;

          aadharController.text = user.aadhar;
          Navigator.pop(dialogContext);
        });
      }
      log(response.body);
    } catch (e) {
      log(e.toString());
    }
  }

  /* getUserDetails() {
    setState(() {
      UserPreferences().getUser().then((value) {
        name = name == '-' ? value.name : name;
        nameController.text = name;

        email = email == '-' ? value.email : email;
        emailController.text = email;

        building = building == '-' ? value.building : building;
        buildingController.text = building;

        areaId = value.areaId;
        areaText = value.areaId != '0' ? value.areaName : areaText;

        ward = ward == '-' ? value.ward : ward;
        wardController.text = ward;

        cityId = value.cityId;
        cityText = value.cityId != '0' ? value.cityName : cityText;

        pincodeText = value.pincode == '0' ? pincodeText : value.pincode;

        aadhar = aadhar == '-' ? value.aadhar : aadhar;
        aadharController.text = aadhar;
      });
    });
  } */

  registrationForm() {
    return Container(
        padding: const EdgeInsets.all(10.0),
        decoration: const BoxDecoration(
          color: AppColors.backgroundcolor,
        ),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
                Widget>[
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
          heading('City'),
          GestureDetector(
            onTap: () {
              getCities();
            },
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: AppColors.appGreen),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(cityText,
                      style: const TextStyle(color: AppColors.lightTextColor)),
                )),
          ),
          heading('Area'),
          GestureDetector(
            onTap: () {
              if (cityText != "Select City") {
                getAreas(cityId);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Please Select city"),
                ));
              }
            },
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: AppColors.appGreen),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(areaText,
                      style: const TextStyle(color: AppColors.lightTextColor)),
                )),
          ),
          heading('Pincode'),
          Container(
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: AppColors.appGreen),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(pincodeText,
                    style: const TextStyle(color: AppColors.lightTextColor)),
              )),
          heading('Building'),
          MyTextField(
            type: TextInputType.streetAddress,
            hint: "Enter your Building",
            key: null,
            myController: buildingController,
          ),
          heading('Ward'),
          MyTextField(
            type: TextInputType.streetAddress,
            hint: "Enter your Ward",
            key: null,
            myController: wardController,
          ),
          heading('Aadhar Number'),
          MyTextField(
            length: 12,
            type: TextInputType.number,
            hint: "Enter your Aadhar Number",
            key: null,
            myController: aadharController,
          )
          /* heading('Phone'),
              MyTextField(
                length: 10,
                type: TextInputType.phone,
                hint: "Enter your Phone Number",
                key: null,
                myController: phoneController,
              ), */
          /* heading('Address'),
              MyTextField(
                type: TextInputType.streetAddress,
                hint: "Enter your Address",
                key: null,
                myController: addressController,
              ),
              heading('Aadhar Number'),
              MyTextField(
                length: 12,
                type: TextInputType.number,
                hint: "Enter your Aadhar Number",
                key: null,
                myController: aadharController,
              ),*/

          ,
          const SizedBox(
            height: 40.0,
          ),
          AppButton(
              title: 'Update',
              onPressed: () {
                NetworkCheckUp().checkConnection().then((value) {
                  if (value) {
                    updateProfile();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please connect to internet."),
                    ));
                  }
                });
              })
        ]));
  }

  void showWaitLoader() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          waitDialogContext = context;
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
                          child: Text('Please wait...')),
                    ],
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
  }

  saveData() {
    name = nameController.text;
    building = buildingController.text;
    ward = wardController.text;
  }

  Future<void> getCities() async {
    try {
      saveData();
      cities = [];
      showWaitLoader();
      String token = '';

      await UserPreferences().getUser().then((value) => {
            token = value.token,
          });
      final Response response = await get(
        Uri.parse(AppUrl.citiesUrl),
        headers: <String, String>{
          'token': token,
        },
      );

      log(response.body);
      if (jsonDecode(response.body)['data'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              jsonDecode(response.body)['message'].toString().toUpperCase()),
        ));
        Navigator.pop(dialogContext);
      } else {
        List<dynamic> list = jsonDecode(response.body)['data'];
        for (int i = 0; i < list.length; i++) {
          log(Cities.fromJson(list[i]).toString());
          cities.add(Cities.fromJson(list[i]));
        }
        Navigator.pop(waitDialogContext);
        _listDialog(1);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> getAreas(String cityId) async {
    try {
      saveData();
      areas = [];
      showWaitLoader();
      String token = '';

      await UserPreferences().getUser().then((value) => {
            token = value.token,
          });
      final Response response = await get(
        Uri.parse(AppUrl.areasUrl + cityId),
        headers: <String, String>{
          'token': token,
        },
      );

      log(response.body);
      if (jsonDecode(response.body)['data'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              jsonDecode(response.body)['message'].toString().toUpperCase()),
        ));
        Navigator.pop(dialogContext);
      } else {
        List<dynamic> list = jsonDecode(response.body)['data'];
        for (int i = 0; i < list.length; i++) {
          areas.add(Areas.fromJson(list[i]));
        }
        Navigator.pop(waitDialogContext);
        _listDialog(2);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  updateList() {
    setState(() {});
  }

  void _listDialog(int i) {
    List list = [];
    if (i == 1) {
      list = cities;
    } else {
      list = areas;
    }
    showDialog(
        barrierDismissible: false,
        context: buildContext,
        builder: (BuildContext context) {
          listDialogContext = context;
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
                backgroundColor: Colors.white,
                child: Container(
                  constraints: const BoxConstraints(
                      minHeight: 0, minWidth: double.infinity, maxHeight: 300),
                  //height: 300.0,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              list = [];
                              if (i == 1) {
                                for (int i = 0; i < cities.length; i++) {
                                  if (cities[i]
                                      .name
                                      .toLowerCase()
                                      .contains(value.toLowerCase())) {
                                    list.add(cities[i]);
                                  }
                                }
                              } else {
                                for (int i = 0; i < areas.length; i++) {
                                  if (areas[i]
                                      .name
                                      .toLowerCase()
                                      .contains(value.toLowerCase())) {
                                    list.add(areas[i]);
                                  }
                                }
                              }
                            });
                          },
                          decoration: const InputDecoration(hintText: 'Search'),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            // itemCount: (i == 1) ? cities.length : areas.length,
                            itemCount: list.length,
                            itemBuilder: (context, position) {
                              return GestureDetector(
                                child: ListTile(
                                  title: Text(list[position].name),
                                  /* title: Text((i == 1)
                                      ? cities[position].name
                                      : areas[position].name), */
                                ),
                                onTap: () {
                                  Navigator.pop(listDialogContext);
                                  if (i == 1) {
                                    cityText = list[position].name;
                                    cityId = list[position].id;
                                  } else {
                                    areaText = list[position].name;
                                    areaId = list[position].id;
                                    pincodeText = list[position].pincode;
                                    log(pincodeText);
                                  }

                                  updateList();
                                  /* setState(() {
                                    if (i == 1) {
                                      cityText = cities[position].name;
                                      cityId = cities[position].id;
                                    } else if (i == 2) {
                                      areaText = areas[position].name;
                                      areaId = areas[position].id;
                                      pincodeText = areas[position].pincode;
                                    }
                                  }); */
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                ));
          });
        });
  }

  Padding heading(title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: const TextStyle(
            color: AppColors.appTextLightBlue, fontWeight: FontWeight.bold),
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

  Future<void> updateProfile() async {
    try {
      String token = '';
      await UserPreferences().getToken().then((value) => {token = value});

      String name = nameController.text;
      String email = emailController.text;
      //String phone = phoneController.text;
      //String address = addressController.text;
      String aadhar = aadharController.text;
      String building = buildingController.text;
      //String area = areaController.text;
      String ward = wardController.text;
      //String pincode = pincodeController.text;
      //String city = cityController.text;

      showLoader('Please wait...');
      final Response response = await post(
        Uri.parse(AppUrl.updateUser),
        headers: <String, String>{'token': token},
        body: jsonEncode(<String, String>{
          'email': email,
          'name': name,
          'building': building,
          'area': areaId,
          'ward': ward,
          'pincode': pincodeText,
          'city': cityId,
          'aadhar': aadhar
        }),
      );

      log(response.body);

      if (response.statusCode == 200) {
        //log(response.body);
        if (!(jsonDecode(response.body).toString().toLowerCase())
            .contains('data')) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(jsonDecode(response.body).toString().toUpperCase()),
          ));
          Navigator.pop(dialogContext);
        } else {
          Navigator.pop(dialogContext);

          var data = jsonDecode(response.body)['data'];

          /* log(data['name'] +
            "--" +
            data['email'] +
            "--" +
            data['building'] +
            "--" +
            data['area'] +
            "--" +
            data['pincode'] +
            "--" +
            data['ward'] +
            "--" +
            data['city']); */

          UserPreferences userPreferences = UserPreferences();

          await userPreferences.updateUser(
            data['name'] ?? '',
            data['email'] ?? '',
            data['building'] ?? '',
            data['areaid'] ?? '',
            data['area'] ?? '',
            data['pin'] ?? '',
            data['ward'] ?? '',
            data['cityid'] ?? '',
            data['city'] ?? '',
            data['aadhar'] ?? '',
          );
          showLoader('Profile Successfully Updated!');
          setState(() {
            Navigator.pop(dialogContext);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please enter valid details"),
        ));
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
