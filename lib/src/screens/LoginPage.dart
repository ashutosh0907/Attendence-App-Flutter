import 'package:attendify_main/src/constants/image_path.dart';
import 'package:attendify_main/src/constants/url.dart';
import 'package:attendify_main/src/routes/routes_config.dart';
import 'package:attendify_main/src/screens/OTPPage.dart';
import 'package:attendify_main/src/utils/networks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  static get enabled => null;

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String phoneNumber = '';
  static String url = URL.baseUrl;
  var phoneNumberController = TextEditingController();
  var loader = false;

  void sendOtp() async {
    showLoader(context,true);
    var url = '${URL.baseUrl}userSignin?_format=json';
    var payload = {
      'mobile': int.parse(phoneNumberController.text),
    };
    var token = false;
    try {
      var res =
          await NetWork.postNetwork(url: url, payload: payload, token: token);
      if (kDebugMode) {
        print("Result is : $res");
      }
      if (res['code'] == '200') {
        endLoader();
        handleNavigation(res);
      } else {
        endLoader();
        showAlertDialog("Alert", res['message']);
      }
    } catch (error) {
      endLoader();
      showAlertDialog("Alert", "Something went wrong!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   systemOverlayStyle: const SystemUiOverlayStyle(
      //       statusBarColor: Colors.white,
      //       statusBarIconBrightness: Brightness.dark),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height / 2.6,
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.shade900,
                      radius: 50,
                      child: Center(
                        child: Image.asset(ImagePath.splashImg),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Attendify',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontFamily: 'Heading'),
                    ),
                  ),
                  const Text(
                    'Login to your account to log your',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                    ),
                  ),
                  const Text(
                    'attendence',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    )),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.05),
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: TextField(
                        style: const TextStyle(color: Colors.black),
                        controller: phoneNumberController,
                        onChanged: (txt) {},
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: const TextStyle(
                              color: Colors.black87,
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10)),
                            disabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10)),
                            // border: OutlineInputBorder(
                            //     borderSide: BorderSide(color: Colors.black54),
                            //     borderRadius: BorderRadius.circular(10)
                            // ),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10)),
                            prefixIcon: const Icon(
                              Icons.phone_in_talk,
                              color: Colors.black,
                            )),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Text(
                            'Login to your account to log your',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                          Text(
                            'attendance',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.07),
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: TextButton(
                        onPressed: () {
                          if (phoneNumberController.text == '') {
                            showAlertDialog(
                                'Field Empty', 'Please fill the phone number');
                          } else if (phoneNumberController.text.length != 10) {
                            showAlertDialog('Invalid Phone Number',
                                'Please fill the correct 10 digits phone number');
                          } else {
                            sendOtp();
                          }
                        },
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.all(15),
                          primary: Colors.white,
                          backgroundColor: Colors.blue.shade900,
                        ),
                        child: const Text(
                          'Send OTP',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAlertDialog(String title, String msg) {
    Widget okButton = TextButton(
      child: const Text(
        "OK",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        title,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: Text(
        msg,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  // void showLoader(bool val) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     // Prevent dismissing the loader with a tap outside
  //     builder: (BuildContext dialogContext) {
  //       return Center(
  //         child: SizedBox(
  //             width: MediaQuery.of(context).size.width * 0.26,
  //             height: MediaQuery.of(context).size.height * 0.26,
  //             child: Image.asset(ImagePath.loader)),
  //       );
  //     },
  //   );
  // }

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

  void handleNavigation(var res) {
    Navigator.pushNamed(
      context,
      MyRoutes.otp,
      arguments: {
        'otpData': res['data']['otp'],
        'token': res['data']['token'],
        'mobileNumber': phoneNumberController.text
      },
    );
  }
}
