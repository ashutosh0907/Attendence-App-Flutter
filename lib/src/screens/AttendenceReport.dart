import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AttendenceReport extends StatefulWidget {
  const AttendenceReport({super.key});

  @override
  State<AttendenceReport> createState() => _AttendenceReportState();
}

class _AttendenceReportState extends State<AttendenceReport> {


  static const MethodChannel _channel = MethodChannel('wifi_channel');

  static Future<String?> getBSSID() async {
    try {
      return await _channel.invokeMethod('getBSSID');
    } catch (e) {
      if (kDebugMode) {
        print('Error getting BSSID: $e');
      }
      return null;
    }
  }

  void _getBSSID() async {
    String? bssid = await getBSSID();
    if (kDebugMode) {
      print('Wi-Fi BSSID: $bssid');
    }
  }
  @override
  Widget build(BuildContext context) {
    TextEditingController dateController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => {
            // Navigator.pushNamed(context, '/home')
            Navigator.of(context).pop()
          },
        ),
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark),
        title: Text(
          'Attendence Report',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // color: Colors.greenAccent,
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.08,
              child: Center(
                child: Text(
                  'Pick a date to get the attendence Report',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              // color: Colors.red,
              width: MediaQuery.of(context).size.width * 0.8,
              child: TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      labelText: "Enter Date",
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black54),
                      )),
                  readOnly: true,
                  // when true user cannot edit text
                  onTap: () async {
                    //when click we have to show the datepicker
                    DateTime? datePicked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2014),
                        lastDate: DateTime(2027));
                    if (datePicked != null) {
                      print("date selected : ${datePicked} ");
                      dateController.text = DateFormat('yMd').format(datePicked);
                    }
                  }),
            ),
            Container(
              // color: Colors.red,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height*0.1,
              child: Center(
                child: TextButton(
                  onPressed: () {
                    _getBSSID();
                  },
                  style: TextButton.styleFrom(
                    fixedSize: Size.fromWidth(
                        MediaQuery.of(context).size.width * 0.8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Colors.blue.shade900,
                  ),
                  child: const Text(
                    'SHOW DETAILS',
                    style: TextStyle(
                        fontSize: 19,
                        color: Colors.white,
                        fontFamily: 'Heading'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
