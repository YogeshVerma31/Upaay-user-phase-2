import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data_models/near_by_model.dart';
import '../utils/network_connecttion.dart';

class NearByScreen extends StatefulWidget {
  String? title;
  String? name;
  String? type;


  NearByScreen({Key? key, this.title,this.name, this.type}) : super(key: key);

  @override
  State<NearByScreen> createState() => NearByScreenState();
}

class NearByScreenState extends State<NearByScreen> {
  Completer<GoogleMapController> controller = Completer<GoogleMapController>();
  List<Results>? mapResults = [];
  var listOfMarkers = <Marker>[];
  LatLng? latLng;

  int? markerPosition;

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          GoogleMap(
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            mapType: MapType.normal,
            markers: Set<Marker>.of(listOfMarkers),
            initialCameraPosition: CameraPosition(
              target: LatLng(latLng!.latitude, latLng!.longitude),
              zoom: 14.4746,
            ),
            onMapCreated: (GoogleMapController googleMapController) {
              controller.complete(googleMapController);
            },
          ),
          markerPosition != null
              ? Flexible(
            fit: FlexFit.tight,
            child: Container(
              margin: EdgeInsets.only(top: 20),
              width: MediaQuery
                  .of(context)
                  .size
                  .width * .8,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  mapResults![markerPosition!].name!,
                                  style: TextStyle(color: Colors.blue),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                            width: MediaQuery.of(context).size.width*.6,
                          ),
                          Row(
                            children: [
                              InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.topRight,
                                  child: Icon(Icons.directions,),
                                ),
                                onTap: () {
                                  openMap(mapResults![markerPosition!].geometry!
                                      .location!.lat!,
                                      mapResults![markerPosition!].geometry!
                                          .location!.lng!);
                                },
                              ),
                              SizedBox(width: 10,),
                              InkWell(
                                child: Container(
                                  padding: EdgeInsets.all(0),
                                  alignment: Alignment.topRight,
                                  child: Icon(Icons.cancel),
                                ),
                                onTap: () {
                                  setState(() {
                                    markerPosition = null;
                                  });
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Status : ",
                            style: TextStyle(color: Colors.black),
                          ),
                          Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  color: Colors.blue[900],
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5))),
                              child: Text(
                                mapResults![markerPosition!]
                                    .business_status!,
                                style:
                                const TextStyle(color: Colors.white),
                              )),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        children: [
                          const Text(
                            "Rating : ",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            mapResults![markerPosition!]
                                .rating!
                                .toString(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Icon(Icons.star)
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          mapResults![markerPosition!].vicinity!,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              : const SizedBox.shrink(),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the lake!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }

// Future<void> _goToTheLake() async {
//   final GoogleMapController mapController =
//       await controller.controller.future;
//   mapController
//       .animateCamera(CameraUpdate.newCameraPosition(controller.kLake));
// }

  getParkingNearBy(double lat, double lng) async {
    NetworkCheckUp().checkConnection().then((value) async {
      if (value) {
        //showLoader();
        try {
          final Response response = await get(Uri.parse(
              'https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=${widget.name}&location=$lat%2C$lng&radius=10936&type=${widget.type}&key=AIzaSyAsuK3dKiwR9RzV1DzG7Hy9Bw5Wx2eptug'));
          log(
              'https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=${widget.name}&location=-$lat%2C$lng&radius=10936&type=${widget.type}&key=AIzaSyAsuK3dKiwR9RzV1DzG7Hy9Bw5Wx2eptug');
          log(response.body);
          var list = NearByModel.fromJson(jsonDecode(response.body));
          mapResults?.addAll(list.results!);
          setMarkerList();
          //print('hello:' + departments.length.toString());
        } catch (e) {
          log("error" + e.toString());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please connect to internet."),
        ));
      }
    });
  }

  void setMarkerList() {
    print("mapSize" + mapResults!.length.toString());

    setState(() {
      listOfMarkers.addAll(mapResults!
          .map((element) =>
          Marker(
              markerId: MarkerId(element.place_id!),
              onTap: () {
                setState(() {
                  markerPosition = mapResults!.indexOf(element);
                });
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen),
              // infoWindow: InfoWindow(title: element.vicinity),
              position: LatLng(element.geometry!.location!.lat!,
                  element.geometry!.location!.lng!)))
          .toList());
    });

    print("listofMarkerSize" + listOfMarkers.length.toString());
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
    setState(() {
      latLng = LatLng(lat ?? 0, lng ?? 0);
    });
    print(latLng);
    getParkingNearBy(lat!, lng!);
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
