class Areas {
  final String id;
  final String name;
  final String pincode;

  Areas({required this.id, required this.name, required this.pincode});

  factory Areas.fromJson(Map<String, dynamic> responseData) {
    return Areas(
      name: responseData['area'] ?? '',
      id: responseData['id'] ?? '',
      pincode: responseData['pin'] ?? '',
    );
  }
}
