import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app_one/constants/app_urls.dart';
import 'package:flutter_app_one/data_models/my_services.dart';
import 'package:flutter_app_one/data_models/service_count.dart';
import 'package:flutter_app_one/my_widgets/text_field.dart';
import 'package:flutter_app_one/screens/home_screen.dart';
import 'package:flutter_app_one/utils/app_colors.dart';
import 'package:flutter_app_one/utils/network_connecttion.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:http/http.dart';

import 'book_service.dart';
import 'login_screen.dart';

Map serviceCount = {};
List<ServiceCount> mServiceCount = [];
List<MyServices> services = [];

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
// ignore: no_logic_in_create_state
    return _SearchScreenState();
  }
}

class _SearchScreenState extends State<SearchScreen> {
  var searchController = TextEditingController();
  bool showSearch = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => getServices());
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          if (MediaQuery.of(context).viewInsets.bottom > 0) {
            FocusScope.of(context).requestFocus(FocusNode());
          } else {
            if (showSearch) {
              setState(() {
                showSearch = false;
              });
            } else {
              Navigator.pop(context);
              /* Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen())); */
            }
          }
          return false;
        },
        child: Scaffold(
          body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    Positioned(
                      left: 10,
                      top: 20,
                      child: IconButton(
                          icon: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.appTextDarkBlue,
                          ),
                          onPressed: () {
                            if (showSearch) {
                              setState(() {
                                showSearch = false;
                              });
                            } else {
                              Navigator.pop(context);
                              /* Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const HomeScreen())); */
                            }
                          }),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 50.0,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Flexible(
                        flex: 9,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: MyTextField(
                            active: true,
                            myController: searchController,
                            hint: 'Service',
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        child: IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: AppColors.appTextDarkBlue,
                          ),
                          onPressed: () {
                            NetworkCheckUp().checkConnection().then((value) {
                              if (value) {
                                search();
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Please connect to internet."),
                                ));
                              }
                            });
                          },
                        ),
                        /* child: AppButton(
                          title: 'Search',
                          onPressed: () {
                            NetworkCheckUp().checkConnection().then((value) {
                              if (value) {
                                search();
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Please connect to internet."),
                                ));
                              }
                            });
                          },
                        ), */
                      )
                    ],
                  ),
                ),
                Container(
                  child:
                      ((!showSearch) ? getDepartmentList() : getSearchList()),
                ),
              ]),
        ),
      ),
    );
  }

  search() async {
    try {
      var text = searchController.text;
      if (text != '') {
        showLoader();
        services.clear();
        final Response response = await get(Uri.parse(AppUrl.search + text));

        if (jsonDecode(response.body).toString().contains('data')) {
          List<dynamic> list = jsonDecode(response.body)['data'];
          for (int i = 0; i < list.length; i++) {
            services.add(MyServices.fromJson(list[i]));
          }
          setState(() {
            showSearch = true;
            Navigator.pop(dialogContext);
          });
          //getCarousal();
        } else {}
      }
    } catch (e) {
      log(e.toString());
    }
  }

  getDepartmentList() {
    return Expanded(
      child: ListView.builder(
          itemCount: mServiceCount.length,
          itemBuilder: (context, position) {
            return GestureDetector(
              onTap: () {
                checkLogin(mServiceCount[position]);
              },
              child: Row(
                children: <Widget>[
                  Flexible(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Text(
                      mServiceCount[position].count.toString() +
                          '     ' +
                          mServiceCount[position].title,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 20.0, color: AppColors.appTextDarkBlue),
                    ),
                  )),
                ],
              ),
            );
          }),
    );
  }

  getSearchList() {
    return Expanded(
      child: ListView.builder(
          itemCount: services.length,
          itemBuilder: (context, position) {
            return Row(
              children: <Widget>[
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: GestureDetector(
                    child: Text(
                      services[position].title,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 20.0, color: AppColors.appTextDarkBlue),
                    ),
                    onTap: () async {
                      checkLogin(services[position]);
                    },
                  ),
                )),
              ],
            );
          }),
    );
  }

  checkLogin(item) async {
    String token = '';
    await UserPreferences().getUser().then((value) => {token = value.token});
    if (token == '') {
      /* globals.depId = depId;
      globals.item = item;
      globals.gotoBookService = true; */
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => BookServiceScreen(
                    depId: depId,
                    serviceName: item.title,
                    vibhag: item.vibhag,
                    serviceId: item.id,
                  )));
    }
  }

  getServices() async {
    NetworkCheckUp().checkConnection().then((value) async {
      if (value) {
        try {
          showLoader();
          mServiceCount.clear();
          serviceCount.clear();
          final Response response = await get(Uri.parse(AppUrl.services));

          log(response.body);
          if (jsonDecode(response.body).toString().contains('data')) {
            List<dynamic> list = jsonDecode(response.body)['data'];

            List<MyServices> names = [];

            for (int i = 0; i < list.length; i++) {
              names.add(MyServices.fromJson(list[i]));
            }

            for (var names in names) {
              int count = 1;
              if (!serviceCount.containsKey(names)) {
                serviceCount[names] = 1;
                mServiceCount.add(ServiceCount(
                    title: names.title,
                    count: count,
                    id: names.id,
                    vibhag: names.vibhag,
                    depId: int.parse(names.departmentid)));
              } else {
                count++;
                serviceCount[names] += 1;
                mServiceCount.remove(ServiceCount(
                    title: names.title,
                    count: count,
                    id: names.id,
                    vibhag: names.vibhag,
                    depId: int.parse(names.departmentid)));
                mServiceCount.add(ServiceCount(
                    title: names.title,
                    count: count,
                    id: names.id,
                    vibhag: names.vibhag,
                    depId: int.parse(names.departmentid)));
              }
            }
            Navigator.pop(dialogContext);
            setState(() {
              showSearch = false;
            });
          }
        } catch (e) {
          log(e.toString());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please connect to internet."),
        ));
      }
    });
  }

  late BuildContext dialogContext;
  void showLoader() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      CircularProgressIndicator(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text('Please wait...'),
                      ),
                    ],
                  ),
                ),
              ),
              onWillPop: () async => false);
        });
  }
}
