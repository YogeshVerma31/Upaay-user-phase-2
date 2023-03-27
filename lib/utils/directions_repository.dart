import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_app_one/data_models/directions_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_app_one/constants/.env.dart';

class DirectionsRepository {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json?';

  late final Dio _dio;

  DirectionsRepository() : _dio = Dio();

  Future<Directions?> getDirections(
      {required LatLng origin, required LatLng destination}) async {
    final response = await _dio.get(_baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': googleAPIKey,
    });
    if (response.statusCode == 200) {
      log(response.data.toString());
      return Directions.fromMap(response.data);
    }
    return null;
  }
}
