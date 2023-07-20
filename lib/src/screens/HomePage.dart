import 'dart:async';
import 'dart:convert';

import 'package:attendify_main/src/constants/image_path.dart';
import 'package:attendify_main/src/routes/routes_config.dart';
import 'package:attendify_main/src/screens/LoginPage.dart';
import 'package:attendify_main/src/utils/networks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
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
        // leading: Container(
        //     width: 2,
        //     child: Image.asset(ImagePath.menu)),
        // leading: Builder(
        //   builder: (context) {
        //     return IconButton(
        //       // alignment: Alignment.topRight,
        //       icon: Image.asset(
        //         ImagePath.menu,
        //         fit: BoxFit.cover,
        //       ),
        //       onPressed: () => Scaffold.of(context).openDrawer(),
        //     );
        //   }
        // ),
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
                Builder(builder: (context) {
                  return InkWell(
                      onTap: () {
                        if (kDebugMode) {
                          print("object");
                        }
                        Scaffold.of(context).openDrawer();
                      },
                      child: Image.asset(
                        ImagePath.menu,
                        width: 40,
                      ));
                }),
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
                        handleEnd();
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
      drawer: Container(
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

  void setEmployeeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? response = prefs.getString('loginResponse');
    Map<String, dynamic> loginResponse =
    jsonDecode(response!) as Map<String, dynamic>;
    empName = loginResponse['employee']['employee_name'];
    empNo = loginResponse['employee']['employee_no'];
    setState(() {});
  }
  void handleEnd() async {
    if (kDebugMode) {
      print("object");
    }
    var prefs = await SharedPreferences.getInstance();
    if (kDebugMode) {
      print("Update : ${prefs.getBool('started')}");
    }
    bool? breakValue = prefs.getBool('break');
    breakStatus = breakValue ?? false;
    bool? lunchBreakValue = prefs.getBool('lunchBreak');
    lunchBreakStatus = lunchBreakValue ?? false;
    if (kDebugMode) {
      print("breakStatus $breakStatus \nlunchBreakStatus $lunchBreakStatus");
    }
    if(breakStatus == false && lunchBreakStatus == false){
      prefs.setBool('started', false);
      sessionStatus = prefs.getBool('started')!;
      setState(() {});
    } else {
      showAlertDialog1("Invalid Operation", "Your break is running, please end your break and try again? ");
    }
    // prefs.setBool('started', false);
    // sessionStatus = prefs.getBool('started')!;
    // setState(() {});
  }

  // void updateAllStatus() async {
  //   var prefs = await SharedPreferences.getInstance();
  //   sessionStatus = prefs.getBool('started')!;
  //   breakStatus = prefs.getBool('break')!;
  //   lunchBreakStatus = prefs.getBool('lunchBreak')!;
  //   setState(() {});
  // }
  void updateAllStatus() async {
    var prefs = await SharedPreferences.getInstance();
    sessionStatus = prefs.getBool('started') ?? false; // Use false as a default value if 'started' is null
    breakStatus = prefs.getBool('break') ?? false; // Use false as a default value if 'break' is null
    lunchBreakStatus = prefs.getBool('lunchBreak') ?? false; // Use false as a default value if 'lunchBreak' is null
    setState(() {});
  }


  // Triggered when the user clicks on START SESSION
  void handleStart() async {

    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('started', true);
    sessionStatus = prefs.getBool('started')!;
    setState(() {});
  }

  // Triggered when the user clicks on TAKE A BREAK
  void handleBreakStart() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('break', true);
    breakStatus = prefs.getBool('break')!;
    setState(() {});
  }

  // Triggered when the user clicks on END BREAK
  void handleBreakEnd() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('break', false);
    breakStatus = prefs.getBool('break')!;
    setState(() {});
  }

  // Triggered when the user clicks on TAKE LUNCH BREAK
  void handleLunchBreakStart() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('lunchBreak', true);
    lunchBreakStatus = prefs.getBool('lunchBreak')!;
    setState(() {});
  }

  // Triggered when the user clicks on END LUNCH BREAK
  void handleLunchBreakEnd() async {
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('lunchBreak', false);
    lunchBreakStatus = prefs.getBool('lunchBreak')!;
    setState(() {});
  }

  // Triggered when the user clicks on Logout present inside Drawer
  // And inside that handleLogout() is called
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
        "Okay",
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



  // Triggers when user hits END SESSION
  void handleLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }


  void showLoader(bool val) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // Prevent dismissing the loader with a tap outside
      builder: (BuildContext dialogContext) {
        return Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.26,
              height: MediaQuery.of(context).size.height * 0.26,
              child: Image.asset(ImagePath.loader)),
        );
      },
    );
  }

  void endLoader() {
    Navigator.pop(context);
  }
}
