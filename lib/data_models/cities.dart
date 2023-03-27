class Cities {
  String id;
  String name;

  Cities({required this.id, required this.name});

  factory Cities.fromJson(Map<String, dynamic> responseData) {
    return Cities(
      name: responseData['name'] ?? '',
      id: responseData['id'] ?? '',
    );
  }
}
