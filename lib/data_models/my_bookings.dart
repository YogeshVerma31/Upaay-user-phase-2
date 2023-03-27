class MyBooking {
  String id;
  String userId;
  String name;
  String phone;
  String email;
  String address;
  String service;
  String department;
  String departmentId;
  String status;
  String sdescr;
  String addedOn;
  String media;
  String meadia1;
  String vendor;
  String serviceName;
  String building;
  String area;
  String ward;
  String pincode;
  String lat;
  String lng;
  String city;
  String vendorName;
  String rating;
  String ratingOutOf;
  String ratingCount;
  String vendorMessage;
  String happyCode;

  MyBooking(
      {required this.id,
      required this.userId,
      required this.name,
      required this.email,
      required this.phone,
      required this.service,
      required this.department,
      required this.departmentId,
      required this.sdescr,
      required this.media,
      required this.meadia1,
      required this.address,
      required this.vendor,
      required this.status,
      required this.addedOn,
      required this.area,
      required this.building,
      required this.pincode,
      required this.ward,
      required this.lat,
      required this.lng,
      required this.city,
      required this.vendorName,
      required this.rating,
      required this.ratingOutOf,
      required this.ratingCount,
      required this.vendorMessage,
      required this.happyCode,
      this.serviceName = 'Service Name'});

  factory MyBooking.fromJson(Map<String, dynamic> responseData) {
    return MyBooking(
        id: responseData['id'],
        name: responseData['name'],
        email: responseData['email'],
        phone: responseData['phone'],
        addedOn: responseData['added_on'],
        address: responseData['address'],
        status: responseData['status'],
        department: responseData['department_name'] ?? '',
        departmentId: responseData['department'],
        userId: responseData['user_id'],
        meadia1: responseData['media1'],
        media: responseData['media'],
        sdescr: responseData['sdescr'],
        service: responseData['service'],
        vendor: responseData['vendor'] ?? "",
        area: responseData['area'],
        building: responseData['building'],
        lat: responseData['lat'],
        lng: responseData['lng'],
        pincode: responseData['pincode'],
        ward: responseData['ward'],
        city: responseData['city'],
        vendorMessage: responseData['vendor_msg'],
        happyCode: responseData['code'] ?? '',
        rating: responseData['rat'].toString(),
        ratingOutOf: responseData['rat_outof'].toString(),
        ratingCount: responseData['rat_count'].toString(),
        vendorName: responseData['vendor_name'] ?? '',
        serviceName: responseData['service_name'] ?? "");
  }
}
