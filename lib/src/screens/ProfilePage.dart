import 'dart:convert';

import 'package:attendify_main/src/routes/routes_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String empName = "";
  String empNo = "";
  String empMobile = "";
  String empOfficeAddress = "";
  String empHomeAddress = "";
  String empEmail = "";

  @override
  void initState() {
    if (kDebugMode) {
      print("came to user profile");
    }
    setEmployeeData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //  App Bar Color
          backgroundColor: Colors.white,
          //  Status Bar Color
          systemOverlayStyle: const SystemUiOverlayStyle(
              statusBarColor: Colors.white,
              statusBarIconBrightness: Brightness.dark),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () => {
              // Navigator.pushNamed(context, MyRoutes.home)
              Navigator.of(context).pop()
            },
          ),
          title: const Text(
            'User Profile',
            style: TextStyle(color: Colors.black),
          ),
          centerTitle: true,
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: const Alignment(0.8, 1),
                      colors: <Color>[
                        Colors.grey.shade400,
                        Colors.grey.shade400,
                        Colors.grey.shade400,
                        Colors.grey.shade300,
                        Colors.grey.shade300,
                        Colors.grey.shade300,
                        Colors.grey.shade300,
                        Colors.grey.shade300,
                        Colors.grey.shade200,
                      ],
                      tileMode: TileMode.mirror)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade700,
                          // child: Center(
                          //   child:
                          //       Container(child: Image.asset('assets/images/splash.png')),
                          // ),
                          radius: 50,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.55,
                                // height: MediaQuery.of(context).size.height * 0.1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      empName,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'Heading',
                                          color: Colors.black),
                                    ),
                                    const Text(
                                      'Developer Developer',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                    Text(
                                      'Emp. ID : $empNo',
                                      style: const TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        // margin: ,
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(
                          "Email : $empEmail",
                          style: const TextStyle(
                            fontSize: 17,
                            fontFamily: 'Heading',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        // margin: ,
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(
                          "Phone : $empMobile",
                          style: const TextStyle(
                            fontSize: 17,
                            fontFamily: 'Heading',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        // margin: ,
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(
                          "Office Address : $empOfficeAddress",
                          style: const TextStyle(
                            fontSize: 17,
                            fontFamily: 'Heading',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        // margin: ,
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Text(
                          "Home Address : $empHomeAddress",
                          style: const TextStyle(
                            fontSize: 17,
                            fontFamily: 'Heading',
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void setEmployeeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? response = prefs.getString('loginResponse');
    Map<String, dynamic> loginResponse =
        jsonDecode(response!) as Map<String, dynamic>;
    empName = loginResponse['employee']['employee_name'];
    empNo = loginResponse['employee']['employee_no'];
    empMobile = loginResponse['employee']['employee_mobile'];
    empOfficeAddress = loginResponse['employee']['employee_office_address'];
    empHomeAddress = loginResponse['employee']['employee_home_address'];
    empEmail = loginResponse['employee']['employee_email'];
    setState(() {});
    if (kDebugMode) {
      print("loginResponse -> $loginResponse");
      print("Name -> ${loginResponse['employee']['employee_name']}");
      print("Emp ID -> ${loginResponse['employee']['employee_no']}");
      print("Phone Number -> ${loginResponse['employee']['employee_mobile']}");
      print(
          "Emp Office Address -> ${loginResponse['employee']['employee_office_address']}");
      print(
          "Emp Home Address -> ${loginResponse['employee']['employee_home_address']}");
    }
  }
}
