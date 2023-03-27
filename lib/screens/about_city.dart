import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app_one/data_models/about_city.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart';

import '../constants/app_urls.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';

class AboutCityScreen extends StatefulWidget {
  int? from;

  AboutCityScreen({Key? key, this.from}) : super(key: key);

  @override
  State<AboutCityScreen> createState() => _AboutCityScreenState();
}

class _AboutCityScreenState extends State<AboutCityScreen> {
  List<Data> aboutCityList = [];

  @override
  void initState() {
    print(widget.from);
    widget.from == 0
        ? getAboutCityData()
        : widget.from == 4
            ? getPhotoData()
            : getHistoryData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundcolor,
        title: Align(
            alignment: const Alignment(-0.25, 0.0),
            child: Text(
              getAppbarTitle(widget.from)!,
              style: const TextStyle(color: AppColors.appTextDarkBlue),
            )),
        elevation: 0.0,
        leading: IconButton(
            icon: const Icon(
              Icons.chevron_left_rounded,
              color: AppColors.appTextDarkBlue,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        child: aboutCityList.isNotEmpty
            ? widget.from != 4
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          AppUrl.baseDomain + aboutCityList[0].image!,
                        ),
                        Html(data: aboutCityList[0].content)
                      ],
                    ),
                  )
                : getPhotoGalleryList()
            : Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: Text('Please wait...'),
                    ),
                  ],
                ),
              ),
      ),
    ));
  }

  Widget? getPhotoGalleryList() {
    return GridView.builder(
        itemCount: aboutCityList.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,crossAxisSpacing: 5,mainAxisSpacing: 2),
        itemBuilder: (BuildContext context, int index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              AppUrl.baseDomain + aboutCityList[index].photo!,
              fit: BoxFit.fill,
            ),
          );
        });
  }

  getAboutCityData() async {
    aboutCityList.clear();
    try {
      final Response response = await get(Uri.parse(AppUrl.aboutCity),
          headers: {"token": await UserPreferences().getToken()});
      log((AppUrl.aboutCity));
      log(response.body);
      var list = AboutCity.fromJson(jsonDecode(response.body));
      setState(() {
        aboutCityList.addAll(list.data!);
      });

      print(list.data?[0].image);
    } catch (e) {
      print(e);
    }
  }

  getHistoryData() async {
    aboutCityList.clear();
    try {
      final Response response = await get(Uri.parse(AppUrl.aboutCityHistory),
          headers: {"token": await UserPreferences().getToken()});
      log((AppUrl.aboutCityHistory));
      log(response.body);
      var list = AboutCity.fromJson(jsonDecode(response.body));
      setState(() {
        aboutCityList.addAll(list.data!);
      });

      print(list.data?[0].image);
    } catch (e) {
      print(e);
    }
  }

  getPhotoData() async {
    aboutCityList.clear();
    try {
      final Response response = await get(Uri.parse(AppUrl.aboutPhotoGallery),
          headers: {"token": await UserPreferences().getToken()});
      log((AppUrl.aboutPhotoGallery));
      log(response.body);
      var list = AboutCity.fromJson(jsonDecode(response.body));
      setState(() {
        aboutCityList.addAll(list.data!);
      });
      print(list.data?[0].image);
    } catch (e) {
      print(e);
    }
  }

  String? getAppbarTitle(position) {
    switch (position) {
      case 0:
        return "About City";
      case 1:
        return "Feedback";
      case 2:
        return "History and Culture";
      case 3:
        return "News and Article";
      case 4:
        return "Photo gallery";
    }
  }
}
