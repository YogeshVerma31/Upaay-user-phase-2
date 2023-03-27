import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_one/data_models/state_city_model.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import '../constants/app_urls.dart';
import '../my_widgets/text_field.dart';
import '../utils/app_colors.dart';
import '../utils/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';

class JalprahariRegScreen extends StatefulWidget {
  const JalprahariRegScreen({Key? key}) : super(key: key);

  @override
  State<JalprahariRegScreen> createState() => _JalprahariRegScreenState();
}

class _JalprahariRegScreenState extends State<JalprahariRegScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  //TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController stateController = TextEditingController();

  File? _pickedImage;
  late BuildContext buildContext, dialogContext, listDialogContext;
  List<StateCity> statesCities = [];
  String stateId = '';

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    //phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    dialogContext = context;
    listDialogContext = context;
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.backgroundcolor,
          title: const Align(
              alignment: Alignment(-0.35, 0.0),
              child: Text(
                "आओ जलप्रहारी बने",
                style: TextStyle(color: AppColors.appTextDarkBlue),
              )),
          elevation: 0.0,
          leading: IconButton(
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: AppColors.appTextDarkBlue,
              ),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: SingleChildScrollView(child: registrationForm()),
      ),
    ));
  }

  registrationForm() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          heading('Full Name (नाम)*'),
          MyTextField(
            type: TextInputType.name,
            hint: "Full Name (नाम)",
            key: null,
            myController: nameController,
          ),
          /* heading('Phone (फ़ोन)*'),
          MyTextField(
            type: TextInputType.name,
            hint: "Phone (फ़ोन)",
            key: null,
            myController: nameController,
          ), */
          heading('Email (ईमेल)*'),
          MyTextField(
            type: TextInputType.emailAddress,
            hint: "Email (ईमेल)",
            key: null,
            myController: emailController,
          ),
          heading('Address (पता)*'),
          MyTextField(
            type: TextInputType.streetAddress,
            hint: "Address (पता)",
            key: null,
            myController: addressController,
          ),
          heading('State (राज्य)*'),
          GestureDetector(
            onTap: () {
              getLists(1);
            },
            child: MyTextField(
              type: TextInputType.name,
              hint: "State (राज्य)",
              key: null,
              active: false,
              myController: stateController,
            ),
          ),
          heading('City (शहर)*'),
          GestureDetector(
            onTap: () {
              if (stateId != '') {
                getLists(2);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Please select state first.'),
                ));
              }
            },
            child: MyTextField(
              type: TextInputType.name,
              hint: "City (शहर)",
              active: false,
              key: null,
              myController: cityController,
            ),
          ),
          heading('Pincode (पिनकोड)*'),
          MyTextField(
              type: TextInputType.number,
              hint: "Pincode (पिनकोड)",
              key: null,
              length: 6,
              myController: pincodeController),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
            child: GestureDetector(
              child: DottedBorder(
                color: Colors.black,
                strokeWidth: 1,
                child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(
                      child: Text('Browse Photo (फ़ोटो डालें)*',
                          style: TextStyle(
                            fontSize: 10,
                          )),
                    )),
              ),
              onTap: () {
                pickImageDialog();
              },
            ),
          ),
          (_pickedImage != null
              ? Image.file(
                  _pickedImage!,
                  width: 150,
                  height: 150,
                )
              : Container()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
            child: ElevatedButton(
                onPressed: () {
                  register();
                },
                child: const Text('Register')),
          ),
        ],
      ),
    );
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

  pickImageDialog() {
    showDialog(
        barrierDismissible: true,
        context: buildContext,
        builder: (BuildContext context) {
          return WillPopScope(
              child: Dialog(
                backgroundColor: AppColors.backgroundcolor,
                child: SizedBox(
                  height: 200,
                  child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Select Image From',
                              style:
                                  TextStyle(color: AppColors.appTextDarkBlue),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    pickImage(1);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.image,
                                        size: 100,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                      Text('Gallery')
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                    pickImage(2);
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 100,
                                        color: AppColors.appTextDarkBlue,
                                      ),
                                      Text('Camera')
                                    ],
                                  ),
                                )
                              ],
                            )
                          ])),
                ),
              ),
              onWillPop: () async => true);
        });
  }

  pickImage(int i) async {
    //saveData();
    final ImagePicker _picker = ImagePicker();
    XFile? photo;

    if (i == 1) {
      photo = await _picker.pickImage(source: ImageSource.gallery);
    } else if (i == 2) {
      photo =
          await _picker.pickImage(source: ImageSource.camera, imageQuality: 25);
    }

    if (photo != null) {
      setState(() {
        _pickedImage = File(photo!.path);
      });
    } else {
      // User canceled the picker
    }
  }

  register() async {
    try {
      String token = '';
      await UserPreferences().getUser().then((value) => {token = value.token});
      log(token);

      if (nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          stateController.text.isNotEmpty &&
          cityController.text.isNotEmpty &&
          pincodeController.text.isNotEmpty &&
          _pickedImage != null) {
        showWaitLoader(1);
        var request = MultipartRequest("POST", Uri.parse(AppUrl.jalprahari));
        request.headers.addAll(<String, String>{"token": token});

        request.fields['name'] = nameController.text;
        request.fields['email'] = emailController.text;
        //request.fields['phone'] = phone;
        request.fields['address'] = addressController.text;
        request.fields['pincode'] = pincodeController.text;
        request.fields['city'] = cityController.text;
        request.fields['state'] = stateController.text;
        request.files.add(MultipartFile(
            'media',
            File(_pickedImage!.path.toString()).readAsBytes().asStream(),
            File(_pickedImage!.path.toString()).lengthSync(),
            filename: _pickedImage!.path.toString().split("/").last,
            contentType: MediaType('image', 'jpeg')));
        /* if (_pickedImage != null) {
          
        } else {
          request.fields['media'] = '';
        } */

        /* log(request.fields.toString());
      log(request.files.toString());
      log(request.headers.toString()); */

        var response = await request.send();
        log(response.toString());
        if (response.statusCode == 200) {
          Navigator.pop(dialogContext);
          showWaitLoader(2);
          var url = '';
          Map? result;
          await Response.fromStream(response).then((value) =>
              result = jsonDecode(value.body) as Map<String, dynamic>);
          url = result!['data'];
          // ignore: deprecated_member_use
          url_launcher.launch(Uri.parse(url).toString());
          Timer(const Duration(seconds: 3), () {
            Navigator.pop(context);
            Navigator.pop(context);
          });
        } else {
          Navigator.pop(dialogContext);
          log(response.statusCode.toString());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("An Error occured"),
          ));
        }
      } else {
        //Navigator.pop(dialogContext);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please fill all the details marked *."),
        ));
      }
    } catch (e) {
      Navigator.pop(dialogContext);
      log(e.toString());
    }
  }

  void showWaitLoader(int i) {
    showDialog(
        barrierDismissible: false,
        context: dialogContext,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                child: SizedBox(
                  height: 100,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        (i == 1)
                            ? const CircularProgressIndicator()
                            : const Icon(
                                Icons.thumb_up,
                                color: AppColors.appGreen,
                              ),
                        Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: (i == 1)
                                ? const Text('Please wait...')
                                : const Text('Registration Successfull!')),
                      ],
                    ),
                  ),
                ),
              ),
              onWillPop: () async => true);
        });
  }

  void _listDialog(int i) {
    List list = [];
    list = statesCities;
    log('here');

    showDialog(
        barrierDismissible: false,
        context: listDialogContext,
        builder: (context) {
          listDialogContext = context;
          return StatefulBuilder(builder: (listDialogContext, setState) {
            return Dialog(
                backgroundColor: Colors.white,
                child: Container(
                    constraints: const BoxConstraints(
                        minHeight: 0,
                        minWidth: double.infinity,
                        maxHeight: 300),
                    //height: 300.0,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                list = [];
                                for (int i = 0; i < statesCities.length; i++) {
                                  if (statesCities[i]
                                      .name
                                      .toLowerCase()
                                      .contains(value.toLowerCase())) {
                                    list.add(statesCities[i]);
                                  }
                                }
                              });
                            },
                            decoration:
                                const InputDecoration(hintText: 'Search'),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemCount: list.length,
                              itemBuilder: (context, position) {
                                return GestureDetector(
                                  child: ListTile(
                                    title: Text(list[position].name),
                                  ),
                                  onTap: () {
                                    Navigator.pop(listDialogContext);

                                    if (i == 1) {
                                      stateController.text =
                                          list[position].name;
                                      stateId = list[position].id;
                                      log(stateController.text);
                                    } else {
                                      cityController.text = list[position].name;
                                    }
                                    updateList();
                                  },
                                );
                              }),
                        ),
                      ],
                    )));
          });
        });
  }

  updateList() {
    setState(() {});
  }

  getLists(int i) {
    if (i == 1) {
      getStateCity(i, AppUrl.states);
    } else {
      getStateCity(i, AppUrl.jcity + stateId);
    }
  }

  Future<void> getStateCity(int i, String url) async {
    try {
      statesCities = [];
      showWaitLoader(1);
      String token = '';

      await UserPreferences().getUser().then((value) => {
            token = value.token,
          });
      final Response response = await get(
        Uri.parse(url),
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
      } else {
        List<dynamic> list = jsonDecode(response.body)['data'];
        if (i == 1) {
          for (int i = 0; i < list.length; i++) {
            statesCities.add(StateCity.stateFromJson(list[i]));
          }
        } else {
          for (int i = 0; i < list.length; i++) {
            statesCities.add(StateCity.cityFromJson(list[i]));
          }
        }

        Navigator.pop(dialogContext);
        _listDialog(i);
      }
    } catch (e) {
      log(e.toString());
    }
  }
}
