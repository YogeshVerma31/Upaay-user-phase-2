class Places {
  String description;
  String placeId;

  Places({required this.description, required this.placeId});

  factory Places.fromJson(Map<dynamic, dynamic> json) {
    return Places(description: json['description'], placeId: json['place_id']);
  }
}
