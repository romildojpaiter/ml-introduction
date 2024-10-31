import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:recoface/pages/face_scan/face_scan_screen.dart';
import 'package:recoface/pages/home_page.dart';

class MySplash extends StatefulWidget {
  const MySplash({super.key});

  @override
  State<MySplash> createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.gif(
      gifPath: 'assets/ai_icon.gif',
      gifWidth: 269,
      gifHeight: 474,
      nextScreen: const HomePage(),
      backgroundColor: const Color.fromRGBO(0, 25, 54, 0),
      duration: const Duration(milliseconds: 3515),
      onInit: () async {
        debugPrint("onInit");
      },
      onEnd: () async {
        debugPrint("onEnd 1");
      },
    );
  }
}
