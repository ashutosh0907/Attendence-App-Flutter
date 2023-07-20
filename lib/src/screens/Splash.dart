import 'dart:async';
import 'dart:convert';

import 'package:attendify_main/src/constants/image_path.dart';
import 'package:attendify_main/src/screens/LoginPage.dart';
import 'package:attendify_main/src/screens/PermissionPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: Image.asset(
            ImagePath.splashImg,
            width: MediaQuery.of(context).size.width * 0.5,
          ),
        ),
      ),
    );
  }

  void checkLogin() async{
    var prefs = await SharedPreferences.getInstance();
    Map<String,dynamic> loginResponse;
    String? response = prefs.getString('loginResponse');
    if(response != null){
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(context,  MaterialPageRoute(builder: (context) => const PermissionPage()));
      });
    } else {
      Timer(const Duration(seconds: 3), () {
        Navigator.pushReplacement(context,  MaterialPageRoute(builder: (context) => const LoginPage()));
      });
    }
  }
}
