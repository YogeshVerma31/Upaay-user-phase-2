import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app_one/constants/app_urls.dart';
import 'package:flutter_app_one/data_models/my_bookings.dart';
import 'package:flutter_app_one/screens/booking_details.dart';
import 'package:flutter_app_one/utils/app_colors.dart';
import 'package:flutter_app_one/utils/network_connecttion.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';
import 'package:http/http.dart';
import 'package:skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

import 'home_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  final bool? login;
  const BookingHistoryScreen({Key? key, this.login}) : super(key: key);

  @override
  _BookingHistoryScreenState createState() => _BookingHistoryScreenState();
}

List<MyBooking> history = [];

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  late BuildContext dialogContext;
  bool showHistory = false;
  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) => getBookingHistory());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
          onWillPop: () async {
            if (widget.login != null && widget.login == true) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => const HomeScreen()),
                (route) => false,
              );
            } else {
              Navigator.pop(context);
            }
            /* Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (BuildContext context) => const HomeScreen()),
              (route) => false,
            ); */
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                  tooltip: 'Call Customer Care',
                  onPressed: () {
                    // ignore: deprecated_member_use
                    url_launcher.launch("tel://18003094747");
                  },
                  icon: Image.asset('assets/images/call_icon.png'),
                )
                /* IconButton(
                    onPressed: () {
                      NetworkCheckUp().checkConnection().then((value) {
                        showHistory = true;
                        if (value) {
                          setState(() {
                            getBookingHistory();
                          });
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("Please connect to internet."),
                          ));
                        }
                      });
                    },
                    icon: const Icon(Icons.replay_rounded,
                        color: AppColors.appTextDarkBlue)) */
              ],
              title: const Align(
                  alignment: Alignment(-0.25, 0.0),
                  child: Text(
                    "Booking History",
                    style: TextStyle(color: AppColors.appTextDarkBlue),
                  )),
              backgroundColor: AppColors.backgroundcolor,
              elevation: 0.0,
              leading: IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: AppColors.appTextDarkBlue,
                  ),
                  onPressed: () {
                    if (widget.login != null && widget.login == true) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const HomeScreen()),
                        (route) => false,
                      );
                    } else {
                      Navigator.pop(context);
                    }
                    /* Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const HomeScreen()),
                      (route) => false,
                    ); */
                  }),
            ),
            body: Column(
              children: <Widget>[
                Expanded(child: (showHistory) ? getList() : getSkeleton())
              ],
            ),
          )),
    );
  }

  getList() {
    return RefreshIndicator(
        onRefresh: () async {
          NetworkCheckUp().checkConnection().then((value) {
            showHistory = !showHistory;
            if (value) {
              setState(() {
                getBookingHistory();
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Please connect to internet."),
              ));
            }
          });
        },
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: history.length,
          itemBuilder: (context, position) {
            return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              BookingDetailsScreen(
                                history: history[position],
                              )));
                },
                child: Container(
                  color: AppColors.appLightBlue,
                  child: Column(
                    children: [
                      Container(
                        height: 5.0,
                        color: Colors.grey.shade200,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(
                            history[position].serviceName,
                            style: const TextStyle(
                                fontSize: 18.0,
                                color: AppColors.appTextDarkBlue),
                          ),
                          subtitle: Text(
                            history[position].addedOn.substring(
                                    0, history[position].addedOn.indexOf(" ")) +
                                " | " +
                                history[position].addedOn.substring(
                                    history[position].addedOn.indexOf(" ")) +
                                " | " +
                                (getStatus(history[position].status)),
                            style: const TextStyle(
                                color: AppColors.lightTextColor),
                          ),
                          trailing: ClipRRect(
                            child: SizedBox(
                              height: 70.0,
                              width: 70.0,
                              child: getImage(position),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
          },
        ));
  }

  getSkeleton() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: 4,
      itemBuilder: (context, position) {
        return Column(
          children: [
            Container(
              height: 5.0,
              color: Colors.grey.shade200,
            ),
            ListTile(
              title: SkeletonLine(
                style: SkeletonLineStyle(
                    height: 16,
                    width: 100,
                    borderRadius: BorderRadius.circular(8)),
              ),
              subtitle: SkeletonLine(
                style: SkeletonLineStyle(
                    height: 16,
                    width: 70,
                    borderRadius: BorderRadius.circular(8)),
              ),
              trailing: const SkeletonAvatar(
                  style: SkeletonAvatarStyle(width: 20, height: 20)),
            ),
          ],
        );
      },
    );
  }

  getStatus(status) {
    if (status == '1') {
      return 'OPEN';
    } else if (status == '3') {
      return 'COMPLETE';
    } else {
      return 'PROCESSING';
    }
  }

  getImage(int position) {
    if (history[position].media != '') {
      return Align(
          alignment: Alignment.centerRight,
          child: Image.network(
            AppUrl.imageUrl + history[position].media,
            width: 70.0,
            fit: BoxFit.fill,
          ));
    } else {
      return Container();
    }
  }

  getBookingHistory() async {
    NetworkCheckUp().checkConnection().then((value) async {
      if (value) {
        //showLoader();
        try {
          history = [];
          String token = '';
          await UserPreferences().getToken().then((value) => token = value);

          final Response response = await get(
              Uri.parse(AppUrl.insertbooking + '/1'),
              headers: <String, String>{'token': token});

          if (!(jsonDecode(response.body).toString().toLowerCase())
              .contains('data')) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(jsonDecode(response.body).toString().toUpperCase()),
            ));
          } else {
            log('booking history --> ' + response.body);
            List<dynamic> list = jsonDecode(response.body)['data'];
            for (int i = 0; i < list.length; i++) {
              history.add(MyBooking.fromJson(list[i]));
            }
            setState(() {
              showHistory = !showHistory;
              //Navigator.pop(dialogContext);
            });
          }
          return history;
        } catch (e) {
          //print(e.toString());
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please connect to internet."),
        ));
      }
    });
  }

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
