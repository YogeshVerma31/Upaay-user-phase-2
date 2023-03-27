import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app_one/my_widgets/text_button.dart';
import 'package:flutter_app_one/screens/login_screen.dart';
import 'package:flutter_app_one/utils/shared_preferences.dart';

final List<String> imgList = [
  'assets/images/slider1.png',
  'assets/images/slider2.png'
];

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const ManuallyControlledSlider();
  }
}

class ManuallyControlledSlider extends StatefulWidget {
  const ManuallyControlledSlider({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ManuallyControlledSliderState();
  }
}

class _ManuallyControlledSliderState extends State<ManuallyControlledSlider> {
  bool skipShown = true;
  int _current = 0;
  final CarouselController controller = CarouselController();

  @override
  void initState() {
    super.initState();
    UserPreferences preferences = UserPreferences();
    preferences.setWelcomeScreenStatus(true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        return false;
      },
      child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/images/background1.png'),
              fit: BoxFit.cover,
            )),
            child: Stack(
              children: <Widget>[
                Builder(
                  builder: (context) {
                    final double height = MediaQuery.of(context).size.height;
                    return CarouselSlider(
                      carouselController: controller,
                      options: CarouselOptions(
                          height: height,
                          viewportFraction: 1.0,
                          enlargeCenterPage: false,
                          autoPlay: false,
                          enableInfiniteScroll: false,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _current = index;
                              if (index == imgList.length - 1) {
                                skipShown = false;
                              } else {
                                skipShown = true;
                              }
                            });
                          }),
                      items: imgList
                          .map((item) => Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Image.asset(
                                        item,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    sliderT(_current),
                                  ]))
                          .toList(),
                    );
                  },
                ),
                Positioned.fill(
                    bottom: 27,
                    child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imgList.asMap().entries.map((entry) {
                              return Container(
                                width: 10.0,
                                height: 10.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.green
                                            : Colors.white)
                                        .withOpacity(
                                            _current == entry.key ? 1.0 : 0.4)),
                              );
                            }).toList()))),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: !skipShown
                      ? const SizedBox.shrink()
                      : MyTextButton(
                          title: 'SKIP',
                          onPressed: skip,
                          size: 22.0,
                        ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: !skipShown
                      ? const SizedBox.shrink()
                      : MyTextButton(
                          title: 'NEXT',
                          onPressed: gotoNextPage,
                          size: 22.0,
                        ),
                ),
              ],
            ),
          )),
    ));
  }

  void skip() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));

    // Navigator.pushReplacement(context,
    //     MaterialPageRoute(builder: (context) => const PseudoLoginScreen()));
  }

  void gotoNextPage() {
    controller.nextPage();
    if (_current == imgList.length - 1) {
      skip();
    }
  }

  Column sliderT(int index) {
    Column container = Column();
    switch (index) {
      case 0:
        container = Column(
          children: const <Widget>[
            Text(
              'Bringing Sewerag fitting\nSolutions to To Your Home',
              style: TextStyle(color: Colors.white, fontSize: 30.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 150.0),
          ],
        );
        break;
      case 1:
        container = Column(
          children: [
            const Text(
              'Find the Right Cure for Your\nSeverage Systems',
              style: TextStyle(color: Colors.white, fontSize: 30.0),
              textAlign: TextAlign.center,
            ),
            IconButton(
              onPressed: gotoNextPage,
              icon: Image.asset('assets/images/lets_start_button.png'),
              iconSize: 150,
            )
          ],
        );
        break;
    }
    return container;
  }
}
