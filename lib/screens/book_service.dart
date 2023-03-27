import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_one/constants/app_urls.dart';
import 'package:flutter_app_one/data_models/areas.dart';
import 'package:flutter_app_one/data_models/cities.dart';
import 'package:flutter_app_one/my_widgets/app_button.dart';
import 'package:flutter_app_one/my_widgets/text_field.dart';
import 'package:flutter_app_one/screens/home_screen.dart';
import 'package:flutter_app_one/screens/mark_location.dart';
import 'package:flutter_app_one/utils/app_colors.dart';
import 'package:flutter_app_one/utils/network_connecttion.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:flutter_app_one/utils/globals.dart' as globals;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../data_models/user.dart';

class BookServiceScreen extends StatefulWidget {
  final int depId;
  final String serviceName;
  final String serviceId;
  final String vibhag;
  final String cameraImgPath = '';
  final bool? login;

  const BookServiceScreen(
      {Key? key,
      String? cameraImgPath,
      required this.depId,
      required this.serviceName,
      required this.serviceId,
      required this.vibhag,
      this.login})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // ignore: no_logic_in_create_state
    return _BookServiceScreenState(
        cameraImgPath, depId, serviceName, vibhag, serviceId);
  }
}

class _BookServiceScreenState extends State<BookServiceScreen>
    with WidgetsBindingObserver {
  final descriptionController = TextEditingController();
  final nameController = TextEditingController();
  final buildingController = TextEditingController();
  final wardController = TextEditingController();
  final landmarkController = TextEditingController();
  VideoPlayerController? _videoController;

  final int depId;
  final String serviceName;
  final String serviceId;
  final String vibhag;
  String cameraImgPath;

  String fileName = '';
  String videoName = '';
  late UserPreferences prefs;

  String cityText = 'Select City';
  String cityId = '0';
  String areaId = '0';
  String areaText = 'Select Area';
  String pincodeText = 'Pincode';
  String name = '-';
  String building = '-';
  String ward = '-';
  double lati = 0;
  double long = 0;

  List<Cities> cities = [];
  List<Areas> areas = [];

  late BuildContext dialogContext, waitDialogContext;
  late BuildContext buildContext;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      super.didChangeAppLifecycleState(state);

      // These are the callbacks
      switch (state) {
        case AppLifecycleState.resumed:
          setState(() {});
          // widget is resumed
          break;
        case AppLifecycleState.inactive:
          // widget is inactive
          break;
        case AppLifecycleState.paused:

          // widget is paused
          break;
        case AppLifecycleState.detached:
          // widget is detached
          break;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => getUserInfo());
    WidgetsBinding.instance?.addObserver(this);
  }

  _BookServiceScreenState(this.cameraImgPath, this.depId, this.serviceName,
      this.vibhag, this.serviceId);

  @override
  void dispose() {
    descriptionController.dispose();
    nameController.dispose();
    buildingController.dispose();
    wardController.dispose();
    landmarkController.dispose();
    if (_pickedVideo != null) {
      _videoController!.dispose();
    }

    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  getUserInfo() async {
    globals.locationUpdated = false;
    try {
      showWaitLoader();

      List<String> array = await getCurrentLocation();
      String lat = array[0].toString();
      String lng = array[1].toString();

      lati = double.parse(lat);
      long = double.parse(lng);

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
          buildingController.text = user.building;

          areaId = user.areaId;
          areaText = user.areaId != '0' ? user.areaName : areaText;

          wardController.text = user.ward;

          cityId = user.cityId;
          cityText = user.cityId != '0' ? user.cityName : cityText;

          pincodeText = user.pincode != '0' ? user.pincode : pincodeText;
        });
      }
      log(response.body);
    } catch (e) {
      log(e.toString());
    } finally {
      Navigator.pop(waitDialogContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return SafeArea(
        child: WillPopScope(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            Scaffold(
                extendBodyBehindAppBar: true,
                appBar: AppBar(
                  backgroundColor: AppColors.backgroundcolor,
                  title: const Align(
                      alignment: Alignment(-0.25, 0.0),
                      child: Text(
                        "Book Service",
                        style: TextStyle(color: AppColors.appTextDarkBlue),
                      )),
                  elevation: 0.0,
                  leading: IconButton(
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: AppColors.appTextDarkBlue,
                      ),
                      onPressed: () {
                        if (widget.login != null && widget.login == true) {
                          Navigator.pushAndRemoveUntil(
                            buildContext,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    const HomeScreen()),
                            (route) => false,
                          );
                        } else {
                          Navigator.pop(context);
                        }
                        /* Navigator.pushAndRemoveUntil(
                          buildContext,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const HomeScreen()),
                          (route) => false,
                        ); */
                      }),
                ),
                body: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: SingleChildScrollView(child: bookingForm())))
          ],
        ),
      ),
      onWillPop: () async {
        if (widget.login != null && widget.login == true) {
          Navigator.pushAndRemoveUntil(
            buildContext,
            MaterialPageRoute(
                builder: (BuildContext context) => const HomeScreen()),
            (route) => false,
          );
        } else {
          Navigator.pop(context);
        }
        /*  Navigator.pushReplacement(
          buildContext,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomeScreen()),
        ); */
        return false;
      },
    ));
  }

  Container bookingForm() {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 70.0),
        padding: const EdgeInsets.all(10.0),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: <
                Widget>[
          heading('Department (विभाग)*'),
          MyTextField(
            active: false,
            hint: vibhag,
          ),
          heading('Service Name (सर्विस)*'),
          MyTextField(
            active: false,
            hint: serviceName,
          ),
          heading('Full Name (नाम)*'),
          MyTextField(
            active: true,
            type: TextInputType.name,
            hint: 'Full Name (नाम)',
            myController: nameController,
          ),
          heading('Building (ग्रह संख्या)*'),
          MyTextField(
            active: true,
            type: TextInputType.streetAddress,
            myController: buildingController,
            hint: 'Building (ग्रह संख्या)',
          ),
          heading('Ward (वार्ड)*'),
          MyTextField(
            active: true,
            type: TextInputType.streetAddress,
            myController: wardController,
            key: null,
            hint: 'Ward (वार्ड)',
          ),
          heading('City (शहर)*'),
          GestureDetector(
            onTap: () {
              NetworkCheckUp().checkConnection().then((value) {
                if (value) {
                  getCities();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please connect to internet."),
                  ));
                }
              });
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
          heading('Area (एरिया)*'),
          GestureDetector(
            onTap: () {
              if (cityText != "Select City") {
                NetworkCheckUp().checkConnection().then((value) {
                  if (value) {
                    getAreas(cityId);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Please connect to internet."),
                    ));
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                    "Please Select city",
                    style: TextStyle(color: AppColors.appTextLightBlue),
                  ),
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
          heading('Pincode (पिनकोड)*'),
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
          heading('Landmark (लैंडमार्क)'),
          MyTextField(
            myController: landmarkController,
            type: TextInputType.multiline,
            hint: "Landmark (लैंडमार्क)",
          ),
          heading('Short Description (विवरण)'),
          MyTextField(
            myController: descriptionController,
            type: TextInputType.multiline,
            hint: "Please write a short description about the problem",
          ),
          const SizedBox(
            height: 40.0,
          ),
          heading('Current Location'),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: FutureBuilder(
                future: getCurrentLocation(), // async work
                builder: (BuildContext context,
                    AsyncSnapshot<List<String>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return const Text('Loading....');
                    default:
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        String lat = snapshot.data![0].toString();
                        String lng = snapshot.data![1].toString();
                        LatLng latLng =
                            LatLng(double.parse(lat), double.parse(lng));
                        locationMarker = Marker(
                          markerId: const MarkerId('position'),
                          infoWindow:
                              const InfoWindow(title: 'Marked location'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen),
                          position: latLng,
                        );

                        return SizedBox(
                          height: 300.0,
                          child: GoogleMap(
                            initialCameraPosition:
                                CameraPosition(target: latLng, zoom: 18),
                            rotateGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            zoomControlsEnabled: false,
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            mapType: MapType.normal,
                            markers: {locationMarker},
                            onMapCreated:
                                (GoogleMapController controller) async {
                              _mapController = controller;
                              locationMarker = Marker(
                                markerId: const MarkerId('position'),
                                infoWindow:
                                    const InfoWindow(title: 'Marked location'),
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueGreen),
                                position: latLng,
                              );
                            },
                          ),
                        );
                      }
                  }
                },
              ),
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppButton(
                  title: 'CHANGE LOCATION',
                  width: 200.0,
                  onPressed: () {
                    NetworkCheckUp().checkConnection().then((value) {
                      if (value) {
                        saveData();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const MarkLocationScreen()),
                        ).then((value) {
                          setState(() {});
                        });
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Please connect to internet."),
                        ));
                      }
                    });
                  }),
            ],
          ),
          const SizedBox(
            height: 40.0,
          ),
          Center(
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          child: DottedBorder(
                            color: Colors.black,
                            strokeWidth: 1,
                            child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Browse Photo (फ़ोटो डालें)',
                                    style: TextStyle(
                                      fontSize: 10,
                                    ))),
                          ),
                          onTap: () {
                            pickImageDialog();
                            //pickFile();
                          },
                        ),
                        //Text(fileName),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          child: DottedBorder(
                            color: Colors.black,
                            strokeWidth: 1,
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text('Browse Video (विडीओ डालें)',
                                  style: TextStyle(
                                    fontSize: 10,
                                  )),
                            ),
                          ),
                          onTap: () {
                            pickVideo();
                          },
                        ),
                        //Text(videoName),
                      ],
                    ),
                  ),
                ]),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                (_pickedImage != null
                    ? Image.file(
                        _pickedImage!,
                        width: 150,
                        height: 150,
                      )
                    : Container()),
                _pickedVideo != null
                    ? SizedBox(
                        width: 120.0,
                        height: 150.0,
                        child: VideoPlayer(_videoController!),
                      )
                    : Container(),
              ],
            ),
          ),
          const SizedBox(
            height: 40.0,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppButton(
                title: 'BOOK NOW',
                width: 200.0,
                onPressed: () async {
                  NetworkCheckUp().checkConnection().then((value) {
                    if (value) {
                      booknow();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please connect to internet."),
                      ));
                    }
                  });
                },
              ),
            ],
          ),
          /* IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              NetworkCheckUp().checkConnection().then((value) {
                if (value) {
                  booknow();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please connect to internet."),
                  ));
                }
              });
            },
            icon: Image.asset('assets/images/book_button.png'),
            iconSize: 40.0,
          ) */
        ]));
  }

  pickImageDialog() {
    showDialog(
        barrierDismissible: true,
        context: buildContext,
        builder: (BuildContext context) {
          dialogContext = context;
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

  File? _pickedImage, _pickedVideo;

  Future<String> getLocationText() async {
    List<String> array = await getCurrentLocation();
    String lat = array[0].toString();
    String lng = array[1].toString();
    return ('latitude: ' + lat.toString() + ', \nlongitude: ' + lng.toString())
        .toString();
  }

  late BuildContext listDialogContext;

  saveData() {
    name = nameController.text;
    building = buildingController.text;
    ward = wardController.text;
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
                      Flexible(flex: 1, child: CircularProgressIndicator()),
                      Flexible(
                        flex: 1,
                        child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 30.0),
                            child: Text('Please wait...')),
                      ),
                    ],
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
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
        builder: (context) {
          listDialogContext = context;
          return StatefulBuilder(builder: (context, setState) {
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
                                      cityText = list[position].name;
                                      cityId = list[position].id;
                                    } else {
                                      areaText = list[position].name;
                                      areaId = list[position].id;
                                      pincodeText = list[position].pincode;
                                      log(pincodeText);
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

  pickImage(int i) async {
    saveData();
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
        if (photo.name.length > 10) {
          fileName = photo.name.substring(0, 10);
        } else {
          fileName = photo.name;
        }
      });
    } else {
      // User canceled the picker
    }
  }

  pickVideo() async {
    saveData();
    final ImagePicker _picker = ImagePicker();

    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      setState(() {
        _pickedVideo = File(video.path);

        _videoController = VideoPlayerController.file(_pickedVideo!)
          ..initialize();

        if (video.name.length > 10) {
          videoName = video.name.substring(0, 10);
        } else {
          videoName = video.name;
        }
      });
    } else {
      // User canceled the picker
    }
  }

  /* pickFile() async {
    saveData();

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      final file = result.files.first;
      media = file;
      setState(() {
        if (file.name.length > 10) {
          fileName = file.name.substring(0, 10);
        } else {
          fileName = file.name;
        }
      });
    } else {
      // User canceled the picker
    }
  }

  pickVideo() async {
    //await saveTempData();
    saveData();

    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      final file = result.files.first;
      media1 = file;
      setState(() {
        if (file.name.length > 10) {
          videoName = file.name.substring(0, 10);
        } else {
          videoName = file.name;
        }
      });
    } else {
      // User canceled the picker
    }
  } */

  saveTempData() async {
    await UserPreferences().saveTempData(
        nameController.text, buildingController.text, wardController.text);
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

  void showLoader(int i) {
    showDialog(
        barrierDismissible: false,
        context: buildContext,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    child: ((i == 1)
                        ? Image.asset(
                            'assets/images/loader.png',
                            width: 100.0,
                          )
                        : Image.asset('assets/images/done.png', width: 100.0)),
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
  }

  Future<List<String>> getCurrentLocation() async {
    String lat = "";
    String lng = "";
    await UserPreferences().getLocation().then((value) {
      lat = value['lat'];
      lng = value['lng'];
    });

    return [lat, lng];
  }

  booknow() async {
    try {
      List<String> array = await getCurrentLocation();
      String lat = array[0].toString();
      String lng = array[1].toString();
      log(lat.toString() + '---' + lng.toString());

      String token = '';
      String email = '';
      String phone = '';
      await UserPreferences().getUser().then((value) =>
          {token = value.token, email = value.email, phone = value.phone});

      if (nameController.text.isNotEmpty &&
          buildingController.text.isNotEmpty &&
          areaText != 'Select Area' &&
          cityText != 'Select City' &&
          pincodeText != 'Pincode' &&
          wardController.text.isNotEmpty) {
        showLoader(1);
        var request = MultipartRequest("POST", Uri.parse(AppUrl.insertbooking));
        request.headers.addAll(<String, String>{"token": token});

        request.fields['name'] = nameController.text;
        request.fields['email'] = email;
        request.fields['phone'] = phone;
        request.fields['service'] = serviceId;
        request.fields['department'] = depId.toString();
        //request.fields['aadhar'] = aadharController.text;
        //request.fields['address'] = addressController.text;
        request.fields['building'] = buildingController.text;
        request.fields['area'] = areaId;
        request.fields['ward'] = wardController.text;
        request.fields['pincode'] = pincodeText;
        request.fields['city'] = cityId;
        request.fields['lat'] = lat;
        request.fields['lng'] = lng;
        request.fields['landmark'] = landmarkController.text;
        request.fields['sdescr'] = descriptionController.text;
        if (fileName != '') {
          /* request.files.add(MultipartFile(
              'media',
              File(media.path.toString()).readAsBytes().asStream(),
              File(media.path.toString()).lengthSync(),
              filename: media.path.toString().split("/").last,
              contentType: MediaType('image', 'jpeg'))); */
          request.files.add(MultipartFile(
              'media',
              File(_pickedImage!.path.toString()).readAsBytes().asStream(),
              File(_pickedImage!.path.toString()).lengthSync(),
              filename: _pickedImage!.path.toString().split("/").last,
              contentType: MediaType('image', 'jpeg')));
        }
        if (videoName != '') {
          request.files.add(MultipartFile(
              'media1',
              File(_pickedVideo!.path.toString()).readAsBytes().asStream(),
              File(_pickedVideo!.path.toString()).lengthSync(),
              filename: _pickedVideo!.path.toString().split("/").last,
              contentType: MediaType('video', 'mp4')));
        }

        /* log(request.fields.toString());
      log(request.files.toString());
      log(request.headers.toString()); */

        var response = await request.send();
        //log(response.toString());
        if (response.statusCode == 200) {
          Navigator.pop(dialogContext);
          showLoader(2);
          Timer(const Duration(seconds: 3), () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const HomeScreen()));
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

  late BuildContext mapDialogContext;
  CameraPosition initialLoaction =
      const CameraPosition(target: LatLng(27, 78), zoom: 14.47);
  late Marker locationMarker = Marker(
    markerId: const MarkerId('position'),
    infoWindow: const InfoWindow(title: 'Marked location'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    position: LatLng(lati, long),
  );
  // ignore: unused_field
  late GoogleMapController _mapController;

  void getLocationDialog() {
    showDialog(
        barrierDismissible: true,
        context: buildContext,
        builder: (BuildContext context) {
          mapDialogContext = context;
          return Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                height: 400.0,
                child: Column(
                  children: [
                    SizedBox(
                      height: 300.0,
                      child: GoogleMap(
                        onTap: _addMarker,
                        initialCameraPosition: initialLoaction,
                        mapType: MapType.hybrid,
                        markers: {locationMarker},
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                      ),
                    ),
                    AppButton(title: 'Select', onPressed: () {})
                  ],
                ),
              ),
            ),
          );
        });
  }

  _addMarker(LatLng pos) {
    setState(() {
      locationMarker = Marker(
        markerId: const MarkerId('position'),
        infoWindow: const InfoWindow(title: 'Marked location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: pos,
      );
    });

    log(pos.latitude.toString() + '---' + pos.longitude.toString());
  }

  // showCamera() async {
  //   Navigator.pushReplacement(
  //       buildContext,
  //       MaterialPageRoute(
  //           builder: (context) => CameraScreen(
  //                 depId: depId,
  //                 serviceName: serviceName,
  //                 vibhag: vibhag,
  //               )));
  // }
}
