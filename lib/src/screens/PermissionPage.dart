import 'dart:convert';

import 'package:attendify_main/src/constants/image_path.dart';
import 'package:attendify_main/src/routes/routes_config.dart';
import 'package:attendify_main/src/screens/OTPPage.dart';
import 'package:attendify_main/src/utils/networks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionPage extends StatefulWidget {
  static get enabled => null;

  const PermissionPage({super.key});

  @override
  State<PermissionPage> createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage> {
  @override
  void initState() {
    setData();
    super.initState();
  }

  bool location = false;
  String empName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            ImagePath.splashImg,
            fit: BoxFit.cover,
            width: 60,
          ),
          // icon: Icon(Icons.arrow_back),
          onPressed: () => {
            // Navigator.of(context).pop()
          },
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height / 3.4,
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: Center(
                    child: Text(
                      'Hello, $empName',
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontFamily: 'Heading'),
                    ),
                  ),
                ),
                SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: Center(
                      child: Image.asset(
                        ImagePath.permission,
                        width: MediaQuery.of(context).size.width * 0.7,
                      ),
                    ))
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  color: Colors.blue.shade800,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  )),
              child: Column(
                children: [
                  // Allow Location Access
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(
                            child: Text(
                          'Allow Location Access',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            ImagePath.location,
                            width: 30,
                          ),
                        )
                      ],
                    ),
                  ),
                  // GPS Button
                  TextButton(
                    onPressed: () async {
                      // checkPermission(Permission.location);
                      if (kDebugMode) {
                        print('clicked on GPS');
                      }
                      PermissionStatus locationStatus =
                          await Permission.location.request();
                      if (locationStatus == PermissionStatus.granted) {
                        if (kDebugMode) {
                          print("granted");
                        }
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   const SnackBar(
                        //     backgroundColor: Colors.greenAccent,
                        //     padding: EdgeInsets.all(15),
                        //     behavior: SnackBarBehavior.floating,
                        //     margin: EdgeInsets.all(30),
                        //     elevation: 30,
                        //     content: Text(
                        //       'Permission Granted',
                        //       style: TextStyle(
                        //           color: Colors.black,
                        //           fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // );
                        setState(() {
                          location = true;
                        });
                      }
                      if (locationStatus == PermissionStatus.denied) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('This Permission is recommended')));
                      }
                      if (locationStatus ==
                          PermissionStatus.permanentlyDenied) {
                        // openAppSettings();
                        showAlertDialog(context);
                      }
                    },
                    style: TextButton.styleFrom(
                      fixedSize: Size.fromWidth(
                          MediaQuery.of(context).size.width * 0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'GPS',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.deepPurple,
                          fontFamily: 'Heading'),
                    ),
                  ),
                  // Connected & Disconnected
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: FractionallySizedBox(
                        widthFactor: 0.4,
                        alignment: Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Visibility(
                                  visible: location,
                                  child: const Text(
                                    'Connected',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.green),
                                  ),
                                ),
                                Visibility(
                                  visible: !location,
                                  child: const Text(
                                    'Disconnected',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Connect to wifi
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Center(
                            child: Text(
                          'Connect to Wifi',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        )),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Image.asset(
                            ImagePath.wifi,
                            width: 30,
                          ),
                        )
                      ],
                    ),
                  ),
                  // Wifi Button
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      fixedSize: Size.fromWidth(
                          MediaQuery.of(context).size.width * 0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: const Text(
                      'WIFI',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.deepPurple,
                          fontFamily: 'Heading'),
                    ),
                  ),
                  // Connected & Disconnected
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: FractionallySizedBox(
                        widthFactor: 0.4,
                        alignment: Alignment.topLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                          child: const Center(
                            child: Text(
                              'Disconnected',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, MyRoutes.home);
                      },
                      style: TextButton.styleFrom(
                        fixedSize: Size.fromWidth(
                            MediaQuery.of(context).size.width * 0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Get Attendence',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.deepPurple,
                            fontFamily: 'Heading'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> checkPermission(Permission permission) async {
    final status = await permission.request();
  }

  void showAlertDialog(BuildContext context) {
    Widget cancelButton = InkWell(
      onTap: () {
        Navigator.of(context).pop();
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          // height: MediaQuery.of(context).size.width * 0.1,
          color: Colors.red,
          child: const Text("Cancel")),
    );
    Widget settingsButton = InkWell(
      onTap: () {
        openAppSettings();
      },
      child: Container(
          padding: const EdgeInsets.all(10),
          // height: MediaQuery.of(context).size.width * 0.1,
          color: Colors.green,
          child: const Text("Settings")),
    );
    AlertDialog alert = AlertDialog(
      title: const Text('Permission denied'),
      content: const Text('Allow access to location'),
      actions: [cancelButton, settingsButton],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void setData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? response = prefs.getString('loginResponse');
    Map<String, dynamic> loginResponse =
        jsonDecode(response!) as Map<String, dynamic>;
    if (kDebugMode) {
      print(
          "On the permission page : : ${loginResponse['employee']['employee_name']}");
    }
    empName = loginResponse['employee']['employee_name'];
    setState(() {});
  }
}
