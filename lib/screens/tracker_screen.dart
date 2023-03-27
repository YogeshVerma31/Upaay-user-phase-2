import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_app_one/constants/app_urls.dart';
import 'package:flutter_app_one/data_models/directions_model.dart';
import 'package:flutter_app_one/utils/directions_repository.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';

import 'booking_history.dart';

class TrackerScreen extends StatefulWidget {
  final String id;
  const TrackerScreen({Key? key, required this.id}) : super(key: key);

  @override
  _TrackerScreenState createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  CameraPosition initialLoaction =
      const CameraPosition(target: LatLng(27, 78), zoom: 14.47);
  late GoogleMapController _controller;
  late Marker vendorMarker = const Marker(markerId: MarkerId('vendor'));
  late Marker userMarker = const Marker(markerId: MarkerId('user'));
  late Timer locationTimer;
  Directions? _info;

  @override
  void dispose() {
    locationTimer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    locationTimer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => getLatestLocation(0));
    WidgetsBinding.instance?.addPostFrameCallback((_) => getLatestLocation(1));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) =>
                    const BookingHistoryScreen()),
            (route) => false,
          );
          return false;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('TRACK'),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) =>
                            const BookingHistoryScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.chevron_left)),
          ),
          body: GoogleMap(
            polylines: {
              if (_info != null)
                Polyline(
                    polylineId: const PolylineId('directions'),
                    color: Colors.red,
                    width: 5,
                    points: _info!.polyLinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList())
            },
            initialCameraPosition: initialLoaction,
            mapType: MapType.normal,
            markers: {vendorMarker, userMarker},
            onMapCreated: (GoogleMapController controller) {
              _controller = controller;
            },
          ),
          /* floatingActionButton: FloatingActionButton.extended(
            tooltip: 'UPDATE LOCATION',
            label: const Text('UPDATE'),
            onPressed: () {
              getLatestLocation();
            },
          ), */
        ),
      ),
    );
  }

  getLatestLocation(int i) async {
    log(widget.id);
    try {
      String token = '';
      await UserPreferences().getToken().then((value) => token = value);
      final Response response = await get(
          Uri.parse(AppUrl.getLatestLocation + widget.id),
          headers: <String, String>{'token': token});
      log(response.body);
      if (jsonDecode(response.body)['data'] != null) {
        log(response.body);
        double lat =
            double.parse((jsonDecode(response.body)['data']['rider_lat']));
        double lng =
            double.parse((jsonDecode(response.body)['data']['rider_lng']));
        LatLng latLng = LatLng(lat, lng);
        double ulat = double.parse(
            (jsonDecode(response.body)['data']['destination_lat']));
        double ulng = double.parse(
            (jsonDecode(response.body)['data']['destination_lng']));
        LatLng ulatLng = LatLng(ulat, ulng);
        //log(latLng.latitude.toString() + "||" + latLng.longitude.toString());
        Uint8List imageData = await getMarker();
        //updateMarker(latLng, imageData);
        if (i == 1) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: latLng, zoom: 14.0)));
        }
        updateMarker(latLng, ulatLng, imageData);
      } else {}
    } catch (e) {
      log(e.toString());
    }
  }

  void updateMarker(LatLng latLng, LatLng ulatLng, Uint8List imageData) async {
    setState(() {
      vendorMarker = Marker(
          markerId: const MarkerId('vendor'),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Vendor Location'),
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      userMarker = Marker(
          markerId: const MarkerId('user'),
          infoWindow: const InfoWindow(title: 'Your Location'),
          position: ulatLng,
          draggable: false,
          zIndex: 2,
          flat: true,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
    });
    final directions = await DirectionsRepository()
        .getDirections(origin: latLng, destination: ulatLng);
    setState(() {
      _info = directions!;
    });
  }

  Future<Uint8List> getMarker() async {
    ByteData carData =
        await DefaultAssetBundle.of(context).load('assets/images/car_icon.png');
    return carData.buffer.asUint8List();
  }
}
