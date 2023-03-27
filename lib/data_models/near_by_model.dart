class NearByModel {
  List<Results>? results;

  NearByModel({this.results});

  factory NearByModel.fromJson(Map<String, dynamic> json) => NearByModel(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => Results.fromJson(e as Map<String, dynamic>))
          .toList());
}

class Results {
  String? business_status;
  String? icon;
  String? icon_background_color;
  String? icon_mask_base_uri;
  String? name;
  String? place_id;
  int? rating;
  String? vicinity;
  Geometry? geometry;

  Results(
      {this.business_status,
      this.icon,
      this.icon_background_color,
      this.icon_mask_base_uri,
      this.name,
      this.place_id,
      this.rating,
      this.vicinity,
      this.geometry});

  factory Results.fromJson(Map<String, dynamic> json) => Results(
        business_status: json['business_status'],
        icon: json['icon'],
        icon_background_color: json['icon_background_color'],
        icon_mask_base_uri: json['icon_mask_base_uri'],
        name: json['name'],
        place_id: json['place_id'],
        rating: json['rating'].toInt(),
        vicinity: json['vicinity'],
        geometry: Geometry.fromJson(json['geometry']),
      );
}

class Geometry {
  LocationNear? location;

  Geometry({this.location});

  factory Geometry.fromJson(Map<String, dynamic> json) =>
      Geometry(location: LocationNear.fromJson(json['location']));
}

class LocationNear {
  double? lat;
  double? lng;

  LocationNear({this.lat, this.lng});

  factory LocationNear.fromJson(Map<String, dynamic> json) =>
      LocationNear(lat: json['lat'], lng: json['lng']);
}
