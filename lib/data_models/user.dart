class User {
  String name;
  String phone;
  String email;
  String aadhar;
  String token;
  String building;
  String areaId;
  String areaName;
  String ward;
  String pincode;
  String cityId;
  String cityName;

  User(
      {required this.name,
      required this.email,
      required this.phone,
      required this.token,
      required this.aadhar,
      required this.building,
      required this.areaId,
      required this.areaName,
      required this.ward,
      required this.pincode,
      required this.cityId,
      required this.cityName});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
        name: responseData['name'] ?? '',
        email: responseData['email'] ?? '',
        phone: responseData['phone'],
        aadhar: responseData['aadhar'] ?? '',
        token: responseData['token'] ?? '',
        building: responseData['building'] ?? '',
        areaId: responseData['areaid'] ?? '',
        areaName: responseData['area'] ?? '',
        ward: responseData['ward'] ?? '',
        pincode: responseData['pin'] ?? '',
        cityId: responseData['cityid'] ?? '',
        cityName: responseData['city'] ?? '');
  }
}
