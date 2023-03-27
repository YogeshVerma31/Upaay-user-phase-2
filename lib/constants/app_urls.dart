class AppUrl {
  static const String baseDomain = 'https://upaay.org.in/';
  static const String baseURL = "https://upaay.org.in/api/authentication";
  static const String sendOtp = "https://upaay.org.in/api/authentication/login";
  static const String verifyOtp =
      "https://upaay.org.in/api/authentication/verify";
  static const String register = baseURL + "/registration";

  static const String baseServices = 'https://upaay.org.in/api';

  static const String departments = baseServices + "/departments";
  static const String services = baseServices + "/services";
  static const String servicesByDepartment = services + "/bydepartmentid/";

  static const String insertbooking = "https://upaay.org.in/api/booking";

  static const String imageUrl = 'https://upaay.org.in/';
  static const String citiesUrl = 'https://upaay.org.in/api/departments/cities';
  static const String areasUrl = 'https://upaay.org.in/api/departments/area/';

  static const String updateUser = 'https://upaay.org.in/api/user';
  static const String search = 'https://upaay.org.in/api/services/search/';
  static const String getLatestLocation =
      'https://upaay.org.in/api/booking/livetrack/';
  static const String jalprahari = 'https://upaay.org.in/api/jalprahri';
  static const String states = 'https://upaay.org.in/api/jalprahri/state';
  static const String jcity = 'https://upaay.org.in/api/jalprahri/city/';

  static const String aboutCity = 'https://upaay.org.in/api/mycity/about/7';
  static const String aboutCityHistory = 'https://upaay.org.in/api/mycity/history/7';
  static const String aboutPhotoGallery = 'https://upaay.org.in/api/mycity/gallery/7';

}
