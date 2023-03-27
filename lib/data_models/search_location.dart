class SearchLocation {
  final double lat;
  final double lng;

  SearchLocation({required this.lat, required this.lng});

  factory SearchLocation.fromJson(Map<dynamic, dynamic> json) {
    return SearchLocation(lat: json['lat'], lng: json['lng']);
  }
}

class Geometry {
  final SearchLocation location;

  Geometry({required this.location});

  factory Geometry.fromJson(Map<dynamic, dynamic> json) {
    return Geometry(location: SearchLocation.fromJson(json['location']));
  }
}

class Place {
  final Geometry geometry;

  Place({required this.geometry});

  factory Place.fromJson(Map<dynamic, dynamic> json) {
    return Place(geometry: Geometry.fromJson(json['geometry']));
  }
}
