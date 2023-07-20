import 'package:attendify_main/src/constants/colors.dart';
import 'package:attendify_main/src/routes/routes_config.dart';
import 'package:attendify_main/src/screens/AttendenceReport.dart';
import 'package:attendify_main/src/screens/HomePage.dart';
import 'package:attendify_main/src/screens/OTPPage.dart';
import 'package:attendify_main/src/screens/PermissionPage.dart';
import 'package:attendify_main/src/screens/ProfilePage.dart';
import 'package:attendify_main/src/screens/Remarks.dart';
import 'package:attendify_main/src/screens/Splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';


import '../screens/LoginPage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: ColorPath.cyan,
            statusBarIconBrightness: Brightness.light,
          ),
          toolbarHeight: 80,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
        primarySwatch: getMaterialColor(ColorPath.cyan),
        // fontFamily: GoogleFonts.lato().fontFamily,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      routes: {
        "/": (context) => const Splash(),
        MyRoutes.login: (context) => const LoginPage(),
        MyRoutes.otp: (context) => const OTPPage(),
        MyRoutes.permission: (context) => const PermissionPage(),
        MyRoutes.home: (context) => const HomePage(),
        MyRoutes.profile: (context) => const ProfilePage(),
        MyRoutes.report: (context) => const AttendenceReport(),
        MyRoutes.remarks: (context) => const Remarks(),
      },
    );
  }
}
