import 'package:flutter_app_one/data_models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  final String _isLoggedIn = 'isLoggedIn';

  Future<bool> saveUser(User user) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (await prefs.setBool(_isLoggedIn, true)) {
      prefs.setString("name", user.name);
      prefs.setString("email", user.email);
      prefs.setString("phone", user.phone);
      prefs.setString("token", user.token);
      prefs.setString("aadhar", user.aadhar);
      prefs.setString("building", user.building);
      prefs.setString("areaid", user.areaId);
      prefs.setString("areaname", user.areaName);
      prefs.setString("ward", user.ward);
      prefs.setString("pincode", user.pincode);
      prefs.setString("cityid", user.cityId);
      prefs.setString("cityname", user.cityName);
      return true;
    } else {
      return false;
    }
  }

  updateUser(
      String name,
      String email,
      String building,
      String areaId,
      String areaName,
      String pincode,
      String ward,
      String cityId,
      String cityName,
      String aadhar) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("name", name);
    prefs.setString("email", email);
    prefs.setString("building", building);
    prefs.setString("areaid", areaId);
    prefs.setString("areaname", areaName);
    prefs.setString("ward", ward);
    prefs.setString("pincode", pincode);
    prefs.setString("cityid", cityId);
    prefs.setString("cityname", cityName);
    prefs.setString("aadhar", aadhar);
    return true;
  }

  setLocation(lat, lng) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("lat", lat);
    prefs.setString("long", lng);
    prefs.setBool("updated", true);
  }

  getLocation() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return {'lat': prefs.getString("lat"), 'lng': prefs.getString("long")};
  }

  setWelcomeScreenStatus(value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("shown", value);
  }

  Future<bool> getWelcomeScreenStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('shown')) {
      bool shown = prefs.getBool("shown") as bool;
      return shown;
    } else {
      return false;
    }
  }

  Future<String> getId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('token')) {
      String id = prefs.getString('userId') as String;
      return id;
    } else {
      return '';
    }
  }

  Future<String> getName() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('token')) {
      String name = prefs.getString('name') as String;
      return name;
    } else {
      return '';
    }
  }

  getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('token')) {
      String email = prefs.getString('email') as String;
      return email;
    } else {
      return '';
    }
  }

  getPhone() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('token')) {
      String phone = prefs.getString('phone') as String;
      return phone;
    } else {
      return '';
    }
  }

  getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('token')) {
      String token = prefs.getString('token') as String;
      return token;
    } else {
      return '';
    }
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    return sharedPreferences.getBool(_isLoggedIn) ?? false;
  }

  Future<User> getUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool(_isLoggedIn) ?? false) {
      String name = prefs.getString('name') as String;
      String email = prefs.getString('email') as String;
      String phone = prefs.getString('phone') as String;
      String token = prefs.getString('token') as String;
      String aadhar = prefs.getString('aadhar') as String;
      String building = prefs.getString('building') as String;
      String areaId = prefs.getString('areaid') as String;
      String areaName = prefs.getString('areaname') as String;
      String ward = prefs.getString('ward') as String;
      String pincode = prefs.getString('pincode') as String;
      String cityId = prefs.getString('cityid') as String;
      String cityName = prefs.getString('cityname') as String;
      return User(
          name: name,
          email: email,
          phone: phone,
          token: token,
          aadhar: aadhar,
          building: building,
          areaId: areaId,
          areaName: areaName,
          ward: ward,
          cityId: cityId,
          cityName: cityName,
          pincode: pincode);
    } else {
      return User(
          name: '',
          email: '',
          phone: '',
          token: '',
          aadhar: '',
          building: '',
          areaId: '',
          areaName: '',
          ward: '',
          pincode: '',
          cityId: '',
          cityName: '');
    }
  }

  void removeUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("name");
    prefs.remove("email");
    prefs.remove("phone");
    prefs.remove("token");
    prefs.remove("aadhar");
    prefs.remove("building");
    prefs.remove("areaid");
    prefs.remove("areaname");
    prefs.remove("ward");
    prefs.remove("pincode");
    prefs.remove("cityid");
    prefs.remove("cityname");
    prefs.remove(_isLoggedIn);
  }

  Future<bool> saveTempData(name, building, ward) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("tname", name);
    prefs.setString("tbuilding", building);
    prefs.setString("tward", ward);

    return true;
  }

  getTempData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = [
      prefs.getString('tname') as String,
      prefs.getString('tbuilding') as String,
      prefs.getString('tward') as String,
    ];
    return data;
  }

  void removeTempData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("tname");
    prefs.remove("tbuilding");
    prefs.remove("tward");
  }
}
