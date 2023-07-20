import 'dart:convert';

import 'package:attendify_main/src/constants/image_path.dart';
import 'package:attendify_main/src/constants/url.dart';
import 'package:attendify_main/src/routes/routes_config.dart';
import 'package:attendify_main/src/utils/networks.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OTPPage extends StatefulWidget {
  static get enabled => null;

  const OTPPage({super.key});

  @override
  State<OTPPage> createState() => _OTPPageState();
}

class _OTPPageState extends State<OTPPage> {
  String name = "";
  var field1 = TextEditingController();
  var field2 = TextEditingController();
  var field3 = TextEditingController();
  var field4 = TextEditingController();
  late String otpData;
  late String tokenFromLogin;
  late String mobileNumber;

  late FocusNode field1FocusNode;
  late FocusNode field2FocusNode;
  late FocusNode field3FocusNode;
  late FocusNode field4FocusNode;

  @override
  void initState() {
    super.initState();

    // Initialize focus nodes
    field1FocusNode = FocusNode();
    field2FocusNode = FocusNode();
    field3FocusNode = FocusNode();
    field4FocusNode = FocusNode();
  }

  @override
  void dispose(){
    field1FocusNode.dispose();
    field2FocusNode.dispose();
    field3FocusNode.dispose();
    field4FocusNode.dispose();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is Map<String, dynamic>) {
      otpData = arguments['otpData'] as String;
      tokenFromLogin = arguments['token'] as String;
      mobileNumber = arguments['mobileNumber'];
      if (kDebugMode) {
        print("Mobile Number ${otpData.split('')}");
      }
      var o = otpData.split('');
      field1.text = o[0];
      field2.text = o[1];
      field3.text = o[2];
      field4.text = o[3];
      if (kDebugMode) {
        print("Received OTP data: $otpData $tokenFromLogin");
      }
    } else {
      if (kDebugMode) {
        print("No OTP data received.");
      }
    }
  }

  void verifyOtp() async {
    showLoader(true);
    if (kDebugMode) {
      print("came inside send OTP");
    }
    var url = '${URL.baseUrl}verifyOtp?_format=json';
    var payload = {
      "mobile": mobileNumber,
      "otp": otpData,
      "token": tokenFromLogin
    };
    var token = false;
    try {
      if (kDebugMode) {
        print("url is $url and the object is $payload");
      }
      var res = await NetWork.postNetwork(url: url, payload: payload, token: token);
      // showAlertDialog( 'OTP','${res['data']['otp']}');
      if (kDebugMode) {
        print("Result is : $res");
      }
      if (res['code'] == '200') {
        saveDataToLocalStorage(res);
        endLoader();
        if (kDebugMode) {
          print('Login Successfull');
        }
        Navigator.pushNamed(
          context,
          MyRoutes.permission,
        );
      } else {
        endLoader();
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
      endLoader();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          // icon: Image.asset(
          //   'assets/images/login.png',
          //   fit: BoxFit.cover,
          // ),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'OTP Verification',
          style: TextStyle(color: Colors.black),
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
            height: MediaQuery.of(context).size.height / 3.5,
            color: Colors.white,
            child: Column(
              children: [
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
                  'We\'ve sent you an OTP to your',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                  ),
                ),
                const Text(
                  'phone, please enter the code.',
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
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.05),
                    width: MediaQuery.of(context).size.width / 1.3,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: TextFormField(
                              focusNode: field1FocusNode,
                              controller: field1,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  // Move focus to previous TextFormField
                                  field1FocusNode.requestFocus();
                                }
                                else if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10)),
                                disabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black87),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: TextFormField(
                              controller: field2,
                              focusNode: field2FocusNode,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  // Move focus to previous TextFormField
                                  field1FocusNode.requestFocus();
                                }
                                else if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10)),
                                disabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black87),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: TextFormField(
                              controller: field3,
                              focusNode: field3FocusNode,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  // Move focus to previous TextFormField
                                  field2FocusNode.requestFocus();
                                }
                                else if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10)),
                                disabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black87),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: TextFormField(
                              controller: field4,
                              focusNode: field4FocusNode,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(1),
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  // Move focus to previous TextFormField
                                  field3FocusNode.requestFocus();
                                }
                                if (value.length == 1) {
                                  FocusScope.of(context).nextFocus();
                                }
                              },
                              decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10)),
                                disabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black54),
                                    borderRadius: BorderRadius.circular(10)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.black87),
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        Text(
                          'Didn\'t recieve OTP?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          'Wait for 00:19 sec',
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
                        verifyOtp();
                        // print(
                        //     "Number is : ${field1.text}${field2.text}${field3.text}${field4.text}");
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: Colors.blue.shade900,
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(fontSize: 24, color: Colors.white),
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

  void showAlertDialog(String title, String msg) {
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(msg),
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

  void saveDataToLocalStorage(var res) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> response = res;
    await prefs.setString('loginResponse', jsonEncode(response));
  }
}
