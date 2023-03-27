import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app_one/data_models/search_location.dart';
import 'package:flutter_app_one/utils/app_colors.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:flutter_app_one/utils/globals.dart' as globals;
import 'package:flutter_app_one/constants/.env.dart';

import '../data_models/places.dart';

class MarkLocationScreen extends StatefulWidget {
  const MarkLocationScreen({Key? key}) : super(key: key);

  @override
  _MarkLocationScreenState createState() => _MarkLocationScreenState();
}

class _MarkLocationScreenState extends State<MarkLocationScreen> {
  final TextEditingController _searchController = TextEditingController();
  late CameraPosition initialLoaction =
      const CameraPosition(target: LatLng(27, 78), zoom: 14.47);
  late Marker locationMarker = const Marker(markerId: MarkerId('position'));
  late GoogleMapController _mapController;
  late BuildContext waitDialogContext, buildContext;
  List<Places> places = [];
  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => getCurrentLocation());
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          tooltip: 'MARK LOCATION',
          label: const Text('DONE'),
          icon: const Icon(Icons.thumb_up),
          onPressed: () {
            try {
              Navigator.pop(context);
            } catch (e) {
              log(e.toString());
            }
          },
        ),
        body: Stack(
          children: [
            GoogleMap(
              onTap: _addMarker,
              initialCameraPosition: initialLoaction,
              mapType: MapType.normal,
              markers: {locationMarker},
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: AppColors.backgroundcolor,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(width: 1, color: AppColors.appGreen)),
                  child: Stack(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Text(
                            '   ',
                            style: TextStyle(color: AppColors.lightTextColor),
                          ),
                          prefixIconConstraints:
                              BoxConstraints(minWidth: 0, minHeight: 0),
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          searchPlace(value);
                        },
                      ),
                      Positioned(
                        right: 10,
                        child: IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.text = '';
                                places.clear();
                              });
                            },
                            icon: const Icon(Icons.close_rounded)),
                      )
                    ],
                  ),
                )),
            if (places.isNotEmpty)
              Positioned(
                top: 65,
                left: 8,
                right: 8,
                child: Container(
                    height: 300,
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundcolor,
                    )),
              ),
            if (places.isNotEmpty)
              Positioned(
                top: 65,
                left: 8,
                right: 8,
                child: SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return ListTile(
                          onTap: () {
                            getLocation(places[index].placeId);
                            places.clear();
                          },
                          title: Text(places[index].description,
                              style: const TextStyle(
                                  color: AppColors.appTextDarkBlue)));
                    },
                    itemCount: places.length,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  searchPlace(searchTerm) async {
    places.clear();
    String searchUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$searchTerm&key=' +
            googleAPIKey;
    try {
      Response _response = await get(Uri.parse(searchUrl));
      List<dynamic> list = jsonDecode(_response.body)['predictions'];
      for (int i = 0; i < list.length; i++) {
        places.add(Places.fromJson(list[i]));
      }
      setState(() {});
    } catch (e) {
      log(e.toString());
    }
  }

  getLocation(String placeId) async {
    String placeDetailsUrl =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=' +
            googleAPIKey;
    try {
      Response _response = await get(Uri.parse(placeDetailsUrl));
      var json = jsonDecode(_response.body);
      var jsonResult = json['result'] as Map<String, dynamic>;
      gotoNewLocation(Place.fromJson(jsonResult));
    } catch (e) {
      log(e.toString());
    }
  }

  gotoNewLocation(Place place) {
    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 18.0)));
    _addMarker(
        LatLng(place.geometry.location.lat, place.geometry.location.lng));
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
    LatLng latLng = LatLng(lat ?? 0, lng ?? 0);

    _mapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: 18.0)));
    _addMarker(latLng);

    //await UserPreferences().setLocation(lat.toString(), lng.toString());
  }

  _addMarker(LatLng pos) async {
    //showWaitLoader();
    await UserPreferences()
        .setLocation(pos.latitude.toString(), pos.longitude.toString());
    globals.locationUpdated = true;
    try {
      setState(() {
        locationMarker = Marker(
          markerId: const MarkerId('position'),
          infoWindow: const InfoWindow(title: 'Marked location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: pos,
        );
      });
    } catch (e) {
      log(e.toString());
    }

    //Navigator.pop(waitDialogContext);
  }

  void showWaitLoader() {
    showDialog(
        barrierDismissible: false,
        context: buildContext,
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
}
