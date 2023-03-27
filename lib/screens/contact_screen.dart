// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_app_one/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        /* Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const HomeScreen()),
          (route) => false,
        ); */
        return false;
      },
      child: SafeArea(
          child: Scaffold(
        /* extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const HomeScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.black,
              )),
        ), */
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset('assets/images/road.png'),
            ),
            Column(
              children: [
                Stack(
                  children: <Widget>[
                    Positioned(
                      top: 20,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                              /* Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const HomeScreen()),
                                (route) => false,
                              ); */
                            },
                            icon: const Icon(
                              Icons.chevron_left,
                              color: AppColors.appTextDarkBlue,
                            )),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 150,
                        ),
                      ),
                    ),
                    /* const SizedBox(
                          width: 20.0,
                        ), */
                    Positioned(
                        top: 20,
                        right: 10,
                        child: IconButton(
                          tooltip: 'Call Customer Care',
                          onPressed: () {
                            url_launcher.launch("tel://+919997667559");
                          },
                          icon: Image.asset('assets/images/call_icon.png'),
                        )),
                  ],
                ),
                /* Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                  ),
                ), */
                const Padding(
                  padding: EdgeInsets.only(top: 80, bottom: 40),
                  child: Text(
                    'CONTACT',
                    style: TextStyle(
                        color: AppColors.appTextDarkBlue,
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: SizedBox(
                    width: 300,
                    child: ListTile(
                        dense: true,
                        title: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                url_launcher.launch("tel://18003094747");
                              },
                              child: const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '1800 309 4747',
                                  style: TextStyle(
                                      color: AppColors.appTextDarkBlue,
                                      fontSize: 18.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        leading: Image.asset(
                          'assets/images/mobile.png',
                          width: 50,
                        )),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: SizedBox(
                    width: 300,
                    child: ListTile(
                        dense: true,
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final Uri params = Uri(
                                      scheme: 'mailto',
                                      path: 'info@upaay.org.in');

                                  var url = params.toString();
                                  launch(url);
                                },
                                child: const Text(
                                  'info@upaay.org.in',
                                  style: TextStyle(
                                      color: AppColors.appTextDarkBlue,
                                      fontSize: 18.0),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  final Uri params = Uri(
                                      scheme: 'mailto',
                                      path: 'help@upaay.org.in');

                                  var url = params.toString();
                                  launch(url);
                                },
                                child: const Text(
                                  'help@upaay.org.in',
                                  style: TextStyle(
                                      color: AppColors.appTextDarkBlue,
                                      fontSize: 18.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        leading: Image.asset(
                          'assets/images/message.png',
                          width: 50,
                        )),
                  ),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }
}
