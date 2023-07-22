import 'dart:async';
import 'dart:convert';

import 'package:attendify_main/src/constants/image_path.dart';
import 'package:attendify_main/src/constants/url.dart';
import 'package:attendify_main/src/routes/routes_config.dart';
import 'package:attendify_main/src/screens/LoginPage.dart';
import 'package:attendify_main/src/utils/networks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  static get enabled => null;

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Item {
  final String imageUrl;
  final String text;
  final String navigation;


  Item({required this.imageUrl, required this.text, required this.navigation});
}

class _HomePageState extends State<HomePage> {
  late String _timeString;
  String name = "";
  String time = "";
  bool sessionStatus = false;
  bool breakStatus = false;
  bool lunchBreakStatus = false;
  String empName = "";
  String empNo = "";
  final double targetLatitude = 20.2956223;
  final double targetLongitude = 85.8425417;
  final double geofenceRadius = 3.0;
  late StreamSubscription<Position> _positionSubscription;
  int i = 0;

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
    // TODO: implement initState
    updateAllStatus(); // To Update The Previous Status Of The Session
    setEmployeeData(); // To Display Dynamic Name On The Drawer
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Item> itemList = [
      Item(
          imageUrl: ImagePath.profile,
          text: 'My Profile',
          navigation: MyRoutes.profile),
      Item(
          imageUrl: ImagePath.report,
          text: 'Attendance Report',
          navigation: MyRoutes.report),
      Item(
          imageUrl: ImagePath.remarks,
          text: 'Remarks',
          navigation: MyRoutes.remarks),
      Item(imageUrl: ImagePath.logout, text: 'Logout', navigation: '')
      // Add more items as needed
    ];
    var datetime = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black, size: 0),
        leadingWidth: MediaQuery.of(context).size.width * 0.99,
        leading: Builder(builder: (context) {
          return IconButton(
            alignment: Alignment.centerRight,
            icon: Image.asset(
              ImagePath.menu,
              fit: BoxFit.cover,
              width: 45,
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
        systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Splash image
                Image.asset(
                  ImagePath.splashImg,
                  width: 90,
                ),
                // Details Container
                Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, $empName',
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Emp Id: $empNo',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
                //Menu Bar
                // Builder(builder: (context) {
                //   return InkWell(
                //       onTap: () {
                //         if (kDebugMode) {
                //           print("object");
                //         }
                //         Scaffold.of(context).openDrawer();
                //       },
                //       child: Image.asset(
                //         ImagePath.menu,
                //         width: 40,
                //       ));
                // }),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.02),
              child: const Center(
                child: Text(
                  'Start your day, log your attendance, and ${'\n'} manage all your attendance any time.',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.04),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Center(
                          child: Text(
                        'Date : ${DateFormat('yMd').format(datetime)}',
                        //     'Date : $time',
                        style: const TextStyle(
                            fontSize: 16, fontFamily: 'Heading'),
                      ))),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.5,
                      child: Center(
                          child: Text(
                        // 'Time : ${DateFormat('jms').format(time)}',
                        'Time: $_timeString',
                        style: const TextStyle(
                            fontSize: 16, fontFamily: 'Heading'),
                      )))
                ],
              ),
            ),
            Visibility(
              // Initially the sessionStatus is false hence !sessionStatus have to be true so that it become visible
              visible: !sessionStatus,
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.3),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        handleStart();
                      },
                      style: TextButton.styleFrom(
                        fixedSize: Size.fromWidth(
                            MediaQuery.of(context).size.width * 0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.greenAccent.shade700,
                      ),
                      child: const Text(
                        'START SESSION',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: 'Heading',
                          // fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              // Initially the sessionStatus is false this section is not visible
              visible: sessionStatus,
              child: Column(
                children: [
                  // Stop Session Button
                  Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: TextButton(
                      onPressed: () {
                        showConfirmDialogue("End session", "Are you sure, do you want to end your today's session?");
                      },
                      style: TextButton.styleFrom(
                        fixedSize: Size.fromWidth(
                            MediaQuery.of(context).size.width * 0.7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: Colors.yellow.shade800,
                      ),
                      child: const Text(
                        'END SESSION',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'Heading',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  // Take a Break
                  Visibility(
                    visible: !breakStatus && !lunchBreakStatus,
                    child: Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.2),
                      child: TextButton(
                        onPressed: () {
                          handleBreakStart();
                        },
                        style: TextButton.styleFrom(
                          fixedSize: Size.fromWidth(
                              MediaQuery.of(context).size.width * 0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.yellow.shade800,
                        ),
                        child: const Text(
                          'TAKE A BREAK',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Heading',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: breakStatus,
                    child: Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.2),
                      child: TextButton(
                        onPressed: () {
                          handleBreakEnd();
                        },
                        style: TextButton.styleFrom(
                          fixedSize: Size.fromWidth(
                              MediaQuery.of(context).size.width * 0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.yellow.shade800,
                        ),
                        child: const Text(
                          'END BREAK',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Heading',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  // Take Lunch Break
                  Visibility(
                    visible: !lunchBreakStatus && !breakStatus,
                    child: Container(
                      // margin: EdgeInsets.only(
                      //     top: MediaQuery.of(context).size.height * 0.4),
                      child: TextButton(
                        onPressed: () {
                          handleLunchBreakStart();
                        },
                        style: TextButton.styleFrom(
                          fixedSize: Size.fromWidth(
                              MediaQuery.of(context).size.width * 0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.yellow.shade800,
                        ),
                        child: const Text(
                          'TAKE LUNCH BREAK',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Heading',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: lunchBreakStatus,
                    child: Container(
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.255),
                      child: TextButton(
                        onPressed: () {
                          handleLunchBreakEnd();
                        },
                        style: TextButton.styleFrom(
                          fixedSize: Size.fromWidth(
                              MediaQuery.of(context).size.width * 0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor: Colors.yellow.shade800,
                        ),
                        child: const Text(
                          'END LUNCH BREAK',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontFamily: 'Heading',
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      endDrawer: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Drawer(
          backgroundColor: Colors.white,
          child: Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.87,
                    height: MediaQuery.of(context).size.height * 0.05,
                    color: Colors.white,
                    child: Container(
                      // color: Colors.grey.shade500,
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Image.asset(ImagePath.cross),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    // width: MediaQuery.sizeOf(context).width / 2,
                    // height: MediaQuery.sizeOf(context).height*0.2,
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.shade900,
                      // child: Center(
                      //   child:
                      //       Container(child: Image.asset('assets/images/splash.png')),
                      // ),
                      radius: 70,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        empName,
                        style: const TextStyle(
                            fontSize: 25,
                            color: Colors.black,
                            fontWeight: FontWeight.w900),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.05),
                        child: Text(
                          'Emp ID : $empNo',
                          style: const TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                if (itemList[index].text == 'Logout') {
                                  showAlertDialog2("Logout",
                                      "Are you sure, do you want to logout?");
                                } else {
                                  Navigator.pushNamed(
                                      context, itemList[index].navigation);
                                }
                              },
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                // color: Colors.red,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        child: Image.asset(
                                          itemList[index].imageUrl,
                                          width: 40,
                                        )),
                                    // Render image
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: Text(itemList[index].text,
                                            style: const TextStyle(
                                                color: Colors.black87,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 20))),
                                  ],
                                ),
                              ),
                            ) // Render text
                          ],
                        );
                      },
                      itemCount: itemList.length,
                      itemExtent: 100,
                      scrollDirection: Axis.vertical,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // On START SESSION geofence is setting up with response code 200
  // Future<void> _setUpGeofence() async {
  //   if (kDebugMode) {
  //     print("Inside _setupGeofence()");
  //   }
  //   Geolocator.getPositionStream().listen((Position position) {
  //     double distanceFromCenter = Geolocator.distanceBetween(
  //       position.latitude,
  //       position.longitude,
  //       targetLatitude,
  //       targetLongitude,
  //     );
  //     if (distanceFromCenter > geofenceRadius) {
  //       _performOutTask();
  //     }
  //     if(distanceFromCenter < geofenceRadius){
  //       _performInTask();
  //     }
  //   });
  // }

  Future<void> _setUpGeofence() async {
    if (kDebugMode) {
      print("Inside _setUpGeofence()");
    }

    _positionSubscription = Geolocator.getPositionStream().listen((Position position) {
      double distanceFromCenter = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        targetLatitude,
        targetLongitude,
      );

      if (distanceFromCenter > geofenceRadius) {
        _performOutTask();
      } else {
        _performInTask();
      }
    });
  }

  // When the user goes outside the geofence
  void _performOutTask() {
    // Replace this with the task you want to perform when the user goes outside the geofence
    if (kDebugMode) {
      print("User went outside the required location. Performing the task.");
    }
    if(breakStatus == false){
      handleBreakStart();
    }
    else {
      if (kDebugMode) {
        print("ashutosh bahar hai ");
      }
    }
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: const Text("Action Triggered"),
    //     content: const Text("Outside the location"),
    //     actions: [
    //       TextButton(
    //         onPressed: submit,
    //         child: const Text("OK"),
    //       ),
    //     ],
    //   ),
    // );
  }

  // When the user comes inside the geofence
  void _performInTask() {
    // Replace this with the task you want to perform when the user goes inside the geofence.
    if (kDebugMode) {
      print("User went outside the required location. Performing the task.");
    }
    if(breakStatus){
      handleBreakEnd();
    } else {
      if (kDebugMode) {
        print("ashutosh andar hai ${i++}");
      }
    }
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: const Text("Action Triggered"),
    //     content: const Text("Inside the location"),
    //     actions: [
    //       TextButton(
    //         onPressed: submit,
    //         child: const Text("OK"),
    //       ),
    //     ],
    //   ),
    // );
  }

  void stopGeofenceUpdates() {
    if (kDebugMode) {
      print("service stopped");
    }
    _positionSubscription.cancel();
  }

  // Triggered whenever the HomePage screen is loaded (This is for setting the name and the Employee number in the UI).
  void setEmployeeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? response = prefs.getString('loginResponse');
    Map<String, dynamic> loginResponse =
        jsonDecode(response!) as Map<String, dynamic>;
    empName = loginResponse['employee']['employee_name'];
    empNo = loginResponse['employee']['employee_no'];
    setState(() {});
  }

  // Triggered whenever the HomePage screen is loaded
  void updateAllStatus() async {
    var prefs = await SharedPreferences.getInstance();
    sessionStatus = prefs.getBool('started') ??
        false; // Use false as a default value if 'started' is null
    breakStatus = prefs.getBool('break') ??
        false; // Use false as a default value if 'break' is null
    lunchBreakStatus = prefs.getBool('lunchBreak') ??
        false; // Use false as a default value if 'lunchBreak' is null
    setState(() {});
  }

  // Triggered when the user clicks on START SESSION
  void handleStart() async {
    showLoader(context, true);
    var url = '${URL.baseUrl}addAttendance?_format=json';
    var payload = {
      "start": "1",
      "attendance_type": 1,
      "lat": "20.2956223",
      "lng": "85.8425417",
      "gateway": "192.168.1.1"
    };
    var token = true;
    try {
      var res =
          await NetWork.postNetwork(url: url, payload: payload, token: token);
      if (res['code'] == '200') {
        _setUpGeofence();
        if (kDebugMode) {
          print("response handleStart() --------------> result is : $res");
        }
        endLoader();
        var prefs = await SharedPreferences.getInstance();
        prefs.setBool('started', true);
        sessionStatus = prefs.getBool('started')!;
        setState(() {});
      } else {
        endLoader();
        if (kDebugMode) {
          print("response handleStart() --------------> result is : $res");
        }
        showAlertDialog1("Alert", res['message']);
      }
    } catch (error) {
      endLoader();
      showAlertDialog1("Alert", "Something went wrong");
    }
  }

  // Triggered when the user clicks on END SESSION
  void handleEnd() async {
    var prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("Update : ${prefs.getBool('started')}");
    }

    // Getting the status of the breaks
    bool? breakValue = prefs.getBool('break');
    breakStatus = breakValue ?? false;
    bool? lunchBreakValue = prefs.getBool('lunchBreak');
    lunchBreakStatus = lunchBreakValue ?? false;
    if (kDebugMode) {
      print("breakStatus $breakStatus \nlunchBreakStatus $lunchBreakStatus");
    }
    // If any one of the break is taken then user is not allowed to END SESSION
    if (breakStatus == false && lunchBreakStatus == false) {
      showLoader(context, true);
      var url = '${URL.baseUrl}addAttendance?_format=json';
      var payload = {
        "start": "0",
        "attendance_type": 1,
        "lat": "20.2956223",
        "lng": "85.8425417",
        "gateway": "192.168.1.1"
      };
      var token = true;
      try {
        var res =
            await NetWork.postNetwork(url: url, payload: payload, token: token);
        if (res['code'] == '200') {
          if (kDebugMode) {
            print("Response code 200 --------------> result is : $res");
          }
          endLoader();
          prefs.setBool('started', false);
          sessionStatus = prefs.getBool('started')!;
          setState(() {});
          stopGeofenceUpdates();
        } else {
          endLoader();
          print("res ------------> $res");
          showAlertDialog1("Alert", "Something went wrong else part!");
        }
      } catch (error) {
        endLoader();
        showAlertDialog1("Alert", "Something went wrong exception!");
      }
    } else {
      showAlertDialog1("Invalid Operation",
          "Your break is running, please end your break and try again? ");
    }
  }

  // Triggered when the user clicks on TAKE A BREAK
  void handleBreakStart() async {
    // final info = NetworkInfo();
    // final wifiName = await info.getWifiName(); // "FooNetwork"
    // final wifiBSSID = await info.getWifiBSSID();
    // if (kDebugMode) {
    //   print("--------------------$wifiName");
    //   print("--------------------$wifiBSSID");
    //   final wifiGateway = await info.getWifiGatewayIP();
    //   print("--------------------$wifiGateway");
    // }
    showLoader(context, true);
    var url = '${URL.baseUrl}addAttendance?_format=json';
    var payload = {
      "start": "1",
      "attendance_type": 3,
      "lat": "20.2956223",
      "lng": "85.8425417",
      "gateway": "192.168.1.1"
    };
    var token = true;
    try {
      var res =
          await NetWork.postNetwork(url: url, payload: payload, token: token);
      if (kDebugMode) {
        print("response handleBreakStart() -------------->  : $res");
      }
      if (res['code'] == '200') {
        if (kDebugMode) {
          print("Response code 200 --------------> result is : $res");
        }
        endLoader();
        var prefs = await SharedPreferences.getInstance();
        prefs.setBool('break', true);
        breakStatus = prefs.getBool('break')!;
        setState(() {});
      } else {
        endLoader();
        showAlertDialog1("Alert", "Something went wrong else part!");
      }
    } catch (error) {
      endLoader();
      showAlertDialog1("Alert", "Something went wrong exception!");
    }
  }

  // Triggered when the user clicks on END BREAK
  void handleBreakEnd() async {
    showLoader(context, true);
    var url = '${URL.baseUrl}addAttendance?_format=json';
    var payload = {
      "start": "0",
      "attendance_type": 3,
      "lat": "20.2956223",
      "lng": "85.8425417",
      "gateway": "192.168.1.1"
    };
    var token = true;
    try {
      var res =
          await NetWork.postNetwork(url: url, payload: payload, token: token);
      if (kDebugMode) {
        print("response handleBreakEnd() -------------->  : $res");
      }
      if (res['code'] == '200') {
        if (kDebugMode) {
          print("Response code 200 --------------> result is : $res");
        }
        endLoader();
        var prefs = await SharedPreferences.getInstance();
        prefs.setBool('break', false);
        breakStatus = prefs.getBool('break')!;
        setState(() {});
      } else {
        endLoader();
        showAlertDialog1("Alert", "Something went wrong else part!");
      }
    } catch (error) {
      endLoader();
      showAlertDialog1("Alert", "Something went wrong exception!");
    }
  }

  // Triggered when the user clicks on TAKE LUNCH BREAK
  void handleLunchBreakStart() async {
    showLoader(context, true);
    var url = '${URL.baseUrl}addAttendance?_format=json';
    var payload = {
      "start": "1",
      "attendance_type": 2,
      "lat": "20.2956223",
      "lng": "85.8425417",
      "gateway": "192.168.1.1"
    };
    var token = true;
    try {
      var res =
          await NetWork.postNetwork(url: url, payload: payload, token: token);
      if (kDebugMode) {
        print("response handleBreakStart() -------------->  : $res");
      }
      if (res['code'] == '200') {
        stopGeofenceUpdates();
        if (kDebugMode) {
          print("Response code 200 --------------> result is : $res");
        }
        endLoader();
        var prefs = await SharedPreferences.getInstance();
        prefs.setBool('lunchBreak', true);
        lunchBreakStatus = prefs.getBool('lunchBreak')!;
        setState(() {});
      } else {
        endLoader();
        showAlertDialog1("Alert", res['message']);
      }
    } catch (error) {
      endLoader();
      showAlertDialog1("Alert", "Something went wrong exception!");
    }
  }

  // Triggered when the user clicks on END LUNCH BREAK
  void handleLunchBreakEnd() async {
    showLoader(context, true);
    var url = '${URL.baseUrl}addAttendance?_format=json';
    var payload = {
      "start": "0",
      "attendance_type": 2,
      "lat": "20.2956223",
      "lng": "85.8425417",
      "gateway": "192.168.1.1"
    };
    var token = true;
    try {
      var res =
          await NetWork.postNetwork(url: url, payload: payload, token: token);
      if (kDebugMode) {
        print("response handleLunchBreakEnd() -------------->  : $res");
      }
      if (res['code'] == '200') {
        if (kDebugMode) {
          print("Response code 200 --------------> result is : $res");
        }
        endLoader();
        var prefs = await SharedPreferences.getInstance();
        prefs.setBool('lunchBreak', false);
        lunchBreakStatus = prefs.getBool('lunchBreak')!;
        setState(() {});
        _setUpGeofence();
      } else {
        endLoader();
        showAlertDialog1("Alert", "Something went wrong else part!");
      }
    } catch (error) {
      endLoader();
      showAlertDialog1("Alert", "Something went wrong exception!");
    }
  }

  // Triggered when the user clicks on Logout present inside Drawer
  // And inside the below function handleLogout() is called
  void showAlertDialog2(String title, String msg) {
    Widget cancelButton = TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(
            color: Colors.green, fontWeight: FontWeight.w900, fontSize: 17),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget confirmButton = TextButton(
      child: const Text(
        "Logout",
        style: TextStyle(
            color: Colors.red, fontWeight: FontWeight.w900, fontSize: 17),
      ),
      onPressed: () async {
        // Clearing the local storage <SharedPreferences> so that whenever user Re-login inside the app then Login Screen will be shown
        // Splash screen has a checking for the SharedPreferences, if there is something inside SharedPreferences
        // Name of the checker function inside Splash.dart file is checkLogin();
        SharedPreferences preferences = await SharedPreferences.getInstance();
        await preferences.clear();
        handleLogout();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w900, fontSize: 19),
      ),
      content: Text(
        msg,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
      ),
      actions: [cancelButton, confirmButton],
    );
    // Showing the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void showAlertDialog1(String title, String msg) {
    Widget confirmButton = TextButton(
      child: const Text(
        "Close",
        style: TextStyle(
            color: Colors.black, fontWeight: FontWeight.w900, fontSize: 17),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w900, fontSize: 19),
      ),
      content: Text(
        msg,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
      ),
      actions: [confirmButton],
    );
    // Showing the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // Below two methods are time specific methods for running the current time
  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _timeString = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('hh:mm:ss').format(dateTime);
  }

  // End of time running methods

  // Triggers when user hits END SESSION
  void handleLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  // Shown whenever showLoader(context, true) is passed to this and the loader is not closing on hardware backpress.
  void showLoader(BuildContext context, bool val) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevent dismissing the loader with a tap outside
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false, // Disable the back button handling
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.26,
              height: MediaQuery.of(context).size.height * 0.26,
              child: Image.asset(ImagePath.loader),
            ),
          ),
        );
      },
    );
  }

  void endLoader() {
    Navigator.pop(context);
  }

  // Triggered whenever the user taps on END SESSION
  void showConfirmDialogue(String title, String msg) {
    Widget cancelButton = TextButton(
      child: const Text(
        "Cancel",
        style: TextStyle(
            color: Colors.green, fontWeight: FontWeight.w900, fontSize: 17),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    Widget confirmButton = TextButton(
      child: const Text(
        "End Session",
        style: TextStyle(
            color: Colors.red, fontWeight: FontWeight.w900, fontSize: 17),
      ),
      onPressed: () async {
        // Ending the session on confirmation
        handleEnd();
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.w900, fontSize: 19),
      ),
      content: Text(
        msg,
        style: const TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
      ),
      actions: [cancelButton, confirmButton],
    );
    // Showing the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
