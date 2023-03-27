// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_app_one/constants/app_urls.dart';
import 'package:flutter_app_one/data_models/my_bookings.dart';
import 'package:flutter_app_one/screens/tracker_screen.dart';
import 'package:flutter_app_one/utils/app_colors.dart';
import 'package:flutter_app_one/utils/network_connecttion.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BookingDetailsScreen extends StatefulWidget {
  final MyBooking history;

  const BookingDetailsScreen({Key? key, required this.history})
      : super(key: key);

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  final GlobalKey<State<StatefulWidget>> _printKey = GlobalKey();
  late BuildContext buildContext;

  late BuildContext dialogContext;
  bool showTrack = false;

  void _printScreen() {
    Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      final doc = pw.Document();

      final image = await WidgetWraper.fromKey(
        key: _printKey,
        pixelRatio: 2.0,
      );

      doc.addPage(pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Expanded(
                child: pw.Image(image),
              ),
            );
          }));

      return doc.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return SafeArea(
        child: WillPopScope(
            onWillPop: () async {
              Navigator.pop(context);
              /* Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) =>
                        const BookingHistoryScreen()),
                (route) => false,
              ); */
              return false;
            },
            child: Scaffold(
              floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    _printScreen();
                  },
                  child: const Icon(
                    Icons.print,
                    color: AppColors.appTextDarkBlue,
                  )),
              backgroundColor: AppColors.backgroundcolor,
              appBar: AppBar(
                title: const Align(
                    //alignment: Alignment(-0.25, 0.0),
                    child: Text(
                  "Details",
                  style: TextStyle(color: AppColors.appTextDarkBlue),
                )),
                backgroundColor: AppColors.backgroundcolor,
                elevation: 0.0,
                actions: [
                  IconButton(
                      tooltip: 'Call Customer Care',
                      icon: Image.asset('assets/images/call_icon.png'),
                      onPressed: () {
                        url_launcher.launch("tel://18003094747");
                      }),
                ],
                leading: IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.appTextDarkBlue,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      /* Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                const BookingHistoryScreen()),
                        (route) => false,
                      ); */
                    }),
              ),
              body: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  padding: const EdgeInsets.all(20.0),
                  margin: const EdgeInsets.only(bottom: 70),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Card(
                          color: Colors.blue.shade50,
                          margin: const EdgeInsets.symmetric(
                              vertical: 20.0, horizontal: 5.0),
                          elevation: 10.0,
                          shadowColor: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                          child: SizedBox(
                            width: 400,
                            child: RepaintBoundary(
                              key: _printKey,
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(20.0),
                                          child: getImage(),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          'Service Name: ' +
                                              widget.history.serviceName,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              color: AppColors.appTextDarkBlue),
                                        ),
                                        Text(
                                          'Service No: ' + widget.history.id,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              color: AppColors.appTextDarkBlue),
                                        ),
                                        Text(
                                          'Description: ' +
                                              widget.history.sdescr,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              color: AppColors.appTextDarkBlue),
                                        ),
                                        getVideo(
                                            widget.history.meadia1.isNotEmpty
                                                ? 1
                                                : 2),
                                        Visibility(
                                            visible: ((widget.history.status ==
                                                        '2' ||
                                                    widget.history.status ==
                                                        '3')
                                                ? true
                                                : false),
                                            child: Text(
                                              'Vendor Name: ' +
                                                  widget.history.vendorName,
                                              style: const TextStyle(
                                                  fontSize: 16.0,
                                                  color: AppColors
                                                      .appTextDarkBlue),
                                            )),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Text(
                                          'Personal Details',
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: AppColors.appTextDarkBlue),
                                        ),
                                        Text(
                                          'Name: ' + widget.history.name,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              color: AppColors.appTextDarkBlue),
                                        ),
                                        Text(
                                          'Phone: ' + widget.history.phone,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              color: AppColors.appTextDarkBlue),
                                        ),
                                        Text(
                                          'Email: ' + widget.history.email,
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              color: AppColors.appTextDarkBlue),
                                        ),
                                        Text(
                                          widget.history.addedOn.substring(
                                                  0,
                                                  widget.history.addedOn
                                                      .indexOf(" ")) +
                                              " | " +
                                              widget.history.addedOn.substring(
                                                  widget.history.addedOn
                                                      .indexOf(" ")) +
                                              " | " +
                                              (getStatus(
                                                  widget.history.status)),
                                          style: const TextStyle(
                                              color: AppColors.appTextDarkBlue),
                                        ),
                                        Visibility(
                                          visible: (widget.history.vendorMessage
                                              .isNotEmpty),
                                          child: Text(
                                            'Vendor Message: ' +
                                                widget.history.vendorMessage,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                color:
                                                    AppColors.appTextDarkBlue),
                                          ),
                                        ),
                                        Visibility(
                                          visible:
                                              (widget.history.happyCode != '0'),
                                          child: Text(
                                            'Happy Code: ' +
                                                widget.history.happyCode,
                                            style: const TextStyle(
                                                fontSize: 16.0,
                                                color:
                                                    AppColors.appTextDarkBlue),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.amber,
                                        child: IconButton(
                                          onPressed: () {
                                            FlutterShare.share(
                                                title: 'Service Details',
                                                text: formatShareText());
                                          },
                                          icon: const Icon(Icons.share),
                                          color: AppColors.appTextDarkBlue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40.0,
                        ),
                        Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.history.rating +
                                              '/' +
                                              widget.history.ratingOutOf +
                                              '\t',
                                          style: const TextStyle(
                                              fontSize: 16.0,
                                              color: AppColors.appTextDarkBlue),
                                        ),
                                        Icon(
                                          Icons.star_rounded,
                                          color: Colors.amber[400],
                                          size: 25,
                                        )
                                      ],
                                    ),
                                    Text(
                                      widget.history.ratingCount + ' Reviews',
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          color: AppColors.appTextDarkBlue),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 40.0,
                                ),
                                Visibility(
                                  visible: (!(widget.history.status == '1' ||
                                      widget.history.status == '3')),
                                  child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  TrackerScreen(
                                                    id: widget.history.id,
                                                  )),
                                          (route) => false,
                                        );
                                      },
                                      child: const Text(
                                        'TRACK',
                                        style: TextStyle(
                                            color: AppColors.appTextDarkBlue,
                                            fontSize: 20.0),
                                      )),
                                )
                                /* OutlinedButton(
                                      onPressed: () {
                                        NetworkCheckUp()
                                            .checkConnection()
                                            .then((value) {
                                          if (value) {
                                            /* Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder:
                                                      (BuildContext context) =>
                                                          ContactScreen(
                                                              widget.history)),
                                              (route) => false,
                                            ); */
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Please connect to internet."),
                                            ));
                                          }
                                        });
                                      },
                                      child: const Text(
                                        'CONTACT',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20.0),
                                      )), */
                              ]),
                        ),
                      ]),
                ),
              ),
            )));
  }

  formatShareText() {
    return 'Service Details--\nService Name: ' +
        widget.history.serviceName +
        '\n' +
        'Service No: ' +
        widget.history.id +
        '\n' +
        'Description: ' +
        widget.history.sdescr +
        '\n\n' +
        'Personal Details--' +
        '\n' +
        'Name: ' +
        widget.history.name +
        '\n' +
        'Phone: ' +
        widget.history.phone +
        '\n' +
        'Email: ' +
        widget.history.email +
        '\n' +
        widget.history.addedOn
            .substring(0, widget.history.addedOn.indexOf(" ")) +
        " | " +
        widget.history.addedOn.substring(widget.history.addedOn.indexOf(" ")) +
        " | " +
        (getStatus(widget.history.status));
  }

  getVideo(int i) {
    if (i == 1) {
      return GestureDetector(
        onTap: () {
          NetworkCheckUp().checkConnection().then((value) {
            if (value) {
              url_launcher.launch(AppUrl.imageUrl + widget.history.meadia1);
              log(AppUrl.imageUrl + widget.history.meadia1);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Please connect to internet."),
              ));
            }
          });
        },
        child: Text(
          'open video',
          style: TextStyle(
              color: Colors.blue.shade800,
              decoration: TextDecoration.underline),
        ),
      );
    } else {
      return const SizedBox();
    }
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

  getImage() {
    if (widget.history.media != '') {
      return GestureDetector(
        onTap: () {
          showImage(widget.history.media);
        },
        child: Align(
            alignment: Alignment.topCenter,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.network(
                  AppUrl.imageUrl + widget.history.media,
                  fit: BoxFit.cover,
                  height: 150,
                ))),
      );
    } else {
      return const SizedBox(
          height: 150, child: Center(child: Text('No Image Available')));
    }
  }

  void showImage(image) {
    showDialog(
        barrierDismissible: true,
        context: buildContext,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
              child: Dialog(
                backgroundColor: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.network(
                    AppUrl.imageUrl + widget.history.media,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              onWillPop: () async => true);
        });
  }
}
